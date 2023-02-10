import uppyFileUpload from "./uppy-file-upload";
import { post } from "@rails/request.js";

const signAttachmentController = (container) => {
  container.querySelectorAll("input[type=file]").forEach((el) => el.remove());

  const url = container.dataset.signAttachmentUrlValue;
  const restrictions = JSON.parse(
    container.dataset.signAttachmentRestrictionsValue
  );
  const trigger = container.querySelector(
    "[data-sign-attachment-target='trigger']"
  );
  const refreshSelector = container.dataset.signAttachmentRefreshSelectorValue;
  const supportWebcam = restrictions.allowedFileTypes.includes("video/*");

  const updateDynamicRestrictions = () => {
    const maxNumberOfFiles =
      (restrictions.maxNumberOfFiles || 0) -
      document.querySelectorAll(`${refreshSelector} > *`).length;
    uppy.setOptions({
      restrictions: {
        ...restrictions,
        maxNumberOfFiles,
      },
    });

    if (maxNumberOfFiles < 1) {
      uppy.getPlugin("Dashboard").setOptions({ disabled: true });
    } else {
      uppy.getPlugin("Dashboard").setOptions({ disabled: false });
    }
  };

  const uppy = uppyFileUpload(container, {
    uppy: { restrictions },
    dashboard: {
      hideRetryButton: true,
      inline: false,
      trigger,
      allowMultipleUploads: false,
      closeAfterFinish: true,
      plugins: supportWebcam ? ["Webcam"] : [],
    },
  });

  uppy.on("dashboard:modal-open", updateDynamicRestrictions);

  uppy.addPostProcessor((fileIds) => {
    const postProcessPromises = fileIds.map((fileId) => {
      const file = uppy.getFile(fileId);
      uppy.emit("postprocess-progress", file, {
        mode: "indeterminate",
        message: "Processing...",
      });

      return post(url, {
        // eslint-disable-next-line camelcase
        body: JSON.stringify({ signed_blob_id: file.response.signed_id }),
      }).then((response) => {
        if (response.statusCode === 422) {
          return response.json.then((errors) =>
            Promise.reject(new Error(errors.join(", ")))
          );
        }
        if (!response.ok) {
          return Promise.reject(
            new Error("Something went wrong creating this sign.")
          );
        }

        $(refreshSelector).load(`${window.location} ${refreshSelector} > *`);

        return Promise.resolve();
      });
    });

    return Promise.all(postProcessPromises);
  });
};

$(() =>
  $("[data-controller='sign-attachment']").each((_idx, container) =>
    signAttachmentController(container)
  )
);
