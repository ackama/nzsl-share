import { initialHTML, errorHTML } from "./file-upload";

const handleCommentAttachmentUpload = ($container) => {
  const $content = $container.find(".file-upload__content");
  const $field = $container.find(`input[name="${$container.data("fileUploadController")}"]`);
  const listSelector = ".video-comment";
  const signId = $container.data("signId");
  const signedBlobId = $field.val();

  // eslint-disable-next-line camelcase
  return $.post(`/signs/${signId}/video_comment`, { signed_blob_id: signedBlobId })
    .done(() => {
      $(listSelector).load(`${window.location} ${listSelector} > *`);
      const fieldName = $field.attr("name");
      $field.filter("input[type='hidden']").remove();
      $content.html(initialHTML(fieldName));
    })
    .fail(xhr => {
      let errorMessage = "Something went wrong.";
      if (xhr.status === 422) { errorMessage = xhr.responseJSON.join(", "); }

      $content.html(errorHTML(errorMessage));
    });
};

const handleCommentReplyAttachmentUpload = ($container) => {
  const $content = $container.find(".file-upload__content");
  const $field = $container.find(`input[name="${$container.data("fileUploadController")}"]`);
  const listSelector = ".video-comment-reply";
  const signId = $container.data("signId");
  const parentId = $container.data("parentId");
  const signedBlobId = $field.val();

  // eslint-disable-next-line camelcase
  return $.post(`/signs/${signId}/video_comment`, { signed_blob_id: signedBlobId, parent_id: parentId })
    .done(() => {
      $(listSelector).load(`${window.location} ${listSelector} > *`);
      const fieldName = $field.attr("name");
      $field.filter("input[type='hidden']").remove();
      $content.html(initialHTML(fieldName));
    })
    .fail(xhr => {
      let errorMessage = "Something went wrong.";
      if (xhr.status === 422) { errorMessage = xhr.responseJSON.join(", "); }

      $content.html(errorHTML(errorMessage));
    });
};

const handleAttachmentRemoval = (type) => $(`.sign-${type}`).load(`${window.location} .sign-${type} > *`);

$(document).on("upload-success", ".video-comment-file-upload-reply", (event) => {
  handleCommentReplyAttachmentUpload($(event.target));
});

$(document).on("upload-success", ".video-comment-file-upload", (event) => {
  handleCommentAttachmentUpload($(event.target));
});

$(document).on("ajax:success", ".video-comment-reply a[data-method='delete']", () => {
  handleAttachmentRemoval("video-comment-reply");
});

$(document).on("ajax:success", ".video-comment a[data-method='delete']", () => {
  handleAttachmentRemoval("video-comment");
});
