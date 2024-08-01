import Rails from '@rails/ujs';
import uppyFileUpload from './uppy-file-upload';
import { post } from '@rails/request.js';
import signVideoRestrictions from './uppy/signVideoRestrictions';

$(document).on('upload-success', '#new_sign .file-upload', () =>
  Rails.fire($('#new_sign').get(0), 'submit')
);

const createSignController = container => {
  container.innerHTML = null; // Reset the container before adding Uppy

  const uppy = uppyFileUpload(container, {
    dashboard: {
      hideRetryButton: true,
      doneButtonHandler: () => {
        dashboard.setOptions({ disabled: true });
        window.location = '/user/signs';
      }
    }
  });

  const dashboard = uppy.getPlugin('Dashboard');

  const maxNumberOfFiles = container.dataset.createSignContributionLimitValue;

  if (!maxNumberOfFiles) {
    throw 'Required option missing: contributionLimitValue';
  }

  uppy.setOptions({
    restrictions: {
      ...signVideoRestrictions,
      maxNumberOfFiles: maxNumberOfFiles
    },
    locale: {
      strings: {
        done: 'Edit My Signs >'
      }
    }
  });

  uppy.addPostProcessor(fileIds => {
    const postProcessPromises = fileIds.map(fileId => {
      const file = uppy.getFile(fileId);
      uppy.emit('postprocess-progress', file, {
        mode: 'indeterminate',
        message: 'Creating signs...'
      });

      return post('/signs', {
        body: JSON.stringify({
          batch: fileIds.length > 1,
          sign: { video: file.response.signed_id }
        })
      }).then(response => {
        if (!response.ok) {
          return Promise.reject(
            new Error('Something went wrong creating this sign.')
          );
        }

        // We check the internal Uppy state to see if a single file has been selected
        // rather than fileIds, since a user can select files in more than one go.
        if (uppy.getFiles().length === 1) {
          window.location = response.headers.get('Location');
        } else {
          return Promise.resolve(); // Do nothing, allow the user to click 'Done'
        }
      });
    });

    return Promise.all(postProcessPromises);
  });
};

$(() => {
  $("[data-controller='create-sign']").each((_idx, container) =>
    createSignController(container)
  );
});
