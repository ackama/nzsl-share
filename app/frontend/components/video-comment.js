import { initialHTML, errorHTML } from './file-upload';

import uppyFileUpload from './uppy-file-upload';
import signVideoRestrictions from './uppy/signVideoRestrictions';

const signVideoCommentController = container => {
  const receiver = container.querySelector(
    "input[data-sign-video-comment-target='receiver']"
  );

  const uppy = uppyFileUpload(container, {
    uppy: {
      restrictions: {
        ...signVideoRestrictions,
        maxNumberOfFiles: 1
      }
    },
    dashboard: {
      hideRetryButton: true
    }
  });

  uppy.on('complete', result => {
    const [file] = result.successful;
    if (!file) {
      return;
    }

    receiver.value = file.response.signed_id;
    receiver.form.requestSubmit();
  });
};

$(() => {
  $("[data-controller='sign-video-comment']").each((_idx, container) =>
    signVideoCommentController(container)
  );
});

const handleCommentAttachmentUpload = $container => {
  const $content = $container.find('.file-upload__content');
  const $field = $container.find(
    `input[name="${$container.data('fileUploadController')}"]`
  );
  const listSelector = '.video-comment';
  const signId = $container.data('signId');
  const signedBlobId = $field.val();
  const folder = document.getElementById('sign_comment_folder');
  const folderId = $(folder).children('option:selected').val();

  $.ajaxSetup({
    headers: { 'X-CSRF-TOKEN': $("meta[name='csrf-token']").attr('content') }
  });

  // eslint-disable-next-line camelcase
  return $.post(`/signs/${signId}/video_comment`, {
    // eslint-disable-next-line camelcase
    signed_blob_id: signedBlobId,
    // eslint-disable-next-line camelcase
    folder_id: folderId,
    format: 'js'
  })
    .done(() => {
      $(listSelector).load(`${window.location} ${listSelector} > *`);
      const fieldName = $field.attr('name');
      $field.filter("input[type='hidden']").remove();
      $content.html(initialHTML(fieldName));
    })
    .fail(xhr => {
      let errorMessage = 'Something went wrong.';
      if (xhr.status === 422) {
        errorMessage = xhr.responseJSON.join(', ');
      }

      $content.html(errorHTML(errorMessage));
    });
};

const handleCommentReplyAttachmentUpload = $container => {
  const $content = $container.find('.file-upload__content');
  const $field = $container.find(
    `input[name="${$container.data('fileUploadController')}"]`
  );
  const listSelector = '.video-comment-reply';
  const signId = $container.data('signId');
  const parentId = $container.data('parentId');
  const signedBlobId = $field.val();
  const folderId = $container.data('folderId');

  $.ajaxSetup({
    headers: { 'X-CSRF-TOKEN': $("meta[name='csrf-token']").attr('content') }
  });

  // eslint-disable-next-line camelcase
  return $.post(`/signs/${signId}/video_comment`, {
    // eslint-disable-next-line camelcase
    signed_blob_id: signedBlobId,
    // eslint-disable-next-line camelcase
    parent_id: parentId,
    // eslint-disable-next-line camelcase
    folder_id: folderId,
    format: 'js'
  })
    .done(() => {
      $(listSelector).load(`${window.location} ${listSelector} > *`);
      const fieldName = $field.attr('name');
      $field.filter("input[type='hidden']").remove();
      $content.html(initialHTML(fieldName));
    })
    .fail(xhr => {
      let errorMessage = 'Something went wrong.';
      if (xhr.status === 422) {
        errorMessage = xhr.responseJSON.join(', ');
      }

      $content.html(errorHTML(errorMessage));
    });
};

const handleAttachmentRemoval = type =>
  $(`.sign-${type}`).load(`${window.location} .sign-${type} > *`);

$(document).on('upload-success', '.video-comment-file-upload-reply', event => {
  handleCommentReplyAttachmentUpload($(event.target));
});

$(document).on('upload-success', '.video-comment-file-upload', event => {
  handleCommentAttachmentUpload($(event.target));
});

$(document).on(
  'ajax:success',
  ".video-comment-reply a[data-method='delete']",
  () => {
    handleAttachmentRemoval('video-comment-reply');
  }
);

$(document).on('ajax:success', ".video-comment a[data-method='delete']", () => {
  handleAttachmentRemoval('video-comment');
});
