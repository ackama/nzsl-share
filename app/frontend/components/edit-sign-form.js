import { initialHTML, errorHTML } from "./file-upload";
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
      trigger: container.querySelector(
        "[data-update-sign-video-target='trigger']"
      ),
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

const handleSignAttachmentUpload = ($container, listSelector, path) => {
  const $content = $container.find(".file-upload__content");
  const $field = $container.find(
    `input[name="${$container.data("fileUploadController")}"]`
  );
  const signId = $container.data("signId");
  const signedBlobId = $field.val();

  // Need to match Rails params
  // eslint-disable-next-line camelcase
  return $.post(`/signs/${signId}/${path}`, { signed_blob_id: signedBlobId })
    .done(() => {
      $(listSelector).load(`${window.location} ${listSelector} > *`);
      const fieldName = $field.attr("name");
      $field.filter("input[type='hidden']").remove();
      $content.html(initialHTML(fieldName));
    })
    .fail((xhr) => {
      let errorMessage = "Something went wrong.";
      if (xhr.status === 422) {
        errorMessage = xhr.responseJSON.join(", ");
      }

      $content.html(errorHTML(errorMessage));
    });
};

const handleAttachmentRemoval = (type) =>
  $(`.sign-${type}`).load(`${window.location} .sign-${type} > *`);

$(document).on("upload-success", ".usage-examples-file-upload", (event) =>
  handleSignAttachmentUpload(
    $(event.target),
    ".sign-usage-examples",
    "usage_examples"
  )
);
$(document).on("upload-success", ".illustrations-file-upload", (event) =>
  handleSignAttachmentUpload(
    $(event.target),
    ".sign-illustrations",
    "illustrations"
  )
);

$(document).on(
  "ajax:success",
  ".sign-usage-examples a[data-method='delete']",
  () => handleAttachmentRemoval("usage-examples")
);
$(document).on(
  "ajax:success",
  ".sign-illustrations a[data-method='delete']",
  () => handleAttachmentRemoval("illustrations")
);

$(document).on("blur keydown", ".js-attachment-description", (event) => {
  if (event.keyCode && event.keyCode !== 13) {
    return;
  }

  event.preventDefault();
  const input = event.target;
  return $.ajax({
    url: input.formAction,
    method: "PATCH",
    data: { format: "js", description: input.value },
  });
});

$(() => {
  $("[data-controller='update-sign-video']").each((_idx, container) =>
    updateSignVideoController(container)
  );
});
