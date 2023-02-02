import uppyFileUpload from "./uppy-file-upload";
import signVideoRestrictions from "./uppy/signVideoRestrictions";
import { put } from "@rails/request.js";

const updateSignVideo = (signId, signedBlobId) => {
  return put(`/signs/${signId}`, {
    body: JSON.stringify({
      sign: { video: signedBlobId },
    }),
  }).then((response) => {
    if (!response.ok) {
      return Promise.reject(
        new Error("Something went wrong creating this sign.")
      );
    }
  });
};

const updateSignVideoController = (container) => {
  const signId = container.dataset.updateSignVideoSignIdValue;
  const trigger = container.querySelector(
    "[data-update-sign-video-target='trigger']"
  );

  if (!signId) {
    console.error(
      "Missing required value [data-update-sign-video-sign-id-value]"
    );
    return;
  }

  const uppy = uppyFileUpload(container, {
    uppy: { restrictions: signVideoRestrictions },
    dashboard: {
      hideRetryButton: true,
      inline: false,
      trigger,
    },
  });

  uppy.addPostProcessor(([fileId]) => {
    const file = uppy.getFile(fileId);
    uppy.emit("postprocess-progress", file, {
      mode: "indeterminate",
      message: "Creating signs...",
    });

    updateSignVideo(signId, file.response.signed_id).then(() => {
      window.location.reload();
    });
  });
};


$(() => {
  $("[data-controller='update-sign-video']").each((_idx, container) =>
    updateSignVideoController(container)
  );
});
