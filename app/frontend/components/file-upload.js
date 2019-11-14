import { DirectUploadController } from "@rails/activestorage/src/direct_upload_controller";

const uploadUrl = "/rails/active_storage/direct_uploads";
const wrapBlobCreateError = (error) => {
  const prefix = "Error creating Blob for";
  const message = error.message ? error.message : error;
  if (!message.startsWith(prefix)) { return error; }
  return "The file you selected does not comply with our upload guidelines.";
};

// Always prevent the default browser behaviour of attempting to open a dropped file
$(document).on("drag dragstart dragend dragover dragenter dragleave drop", event => {
  event.preventDefault();
  event.stopPropagation();
});

const FileUpload = (_index, container) => {
  const $container = $(container).empty();
  const fieldName = $container.data("fileUploadController");
  const $content = $("<div class='file-upload__content'></div>").prependTo($container);
  const $input = $(`<input
                    class="show-for-sr"
                    type="file"
                    name="${fieldName}"
                    id="${fieldName}"
                  />`).appendTo($container);


  $content.html(initialHTML(fieldName));

  $container
    .on("direct-upload:start", $input, () => $content.html(pendingHTML()))
    .on("direct-upload:error", $input, event => $container.trigger("upload-error", event.detail.error) && false)
    .on("dragover dragenter", () => $container.addClass("file-upload--dragged-over"))
    .on("dragleave dragend drop", () => $container.removeClass("file-upload--dragged-over"))
    .on("upload-error", (_event, error) => $content.html(errorHTML(error)))
    .on("click", ".file-upload__reset", (event) => {
      event.preventDefault();
      $content.html(initialHTML(fieldName));
    })
    .on("change", $input, event => {
      const input = $input.get(0);
      const fileSize = input.files[0].size / 1024 / 1024; // in MB

      if (fileSize > 250) { // same file size as app/models/signs.rb MAXIMUM_VIDEO_FILE_SIZE
        return $container.trigger("upload-error", new Error(`Upload failed - file is too large (${Math.round(fileSize)} MB)`));
      }

      input.setAttribute("data-direct-upload-url", uploadUrl);
      input.disabled = true;

      new DirectUploadController(event.target, event.target.files[0])
        .start((error) => {
          input.disabled = false;
          input.removeAttribute("data-direct-upload-url");
          if (error) { return $container.trigger("upload-error", wrapBlobCreateError(error)); }
          $container.trigger("upload-success");
        });
    })
    .on("direct-upload:progress", $input, event => {
      const { progress, file: { name: filename } } = event.detail;
      $content.html(progressHTML(Math.round(progress || 0), filename));
    })
    .on("drop", event => {
      $input
        .prop("files", event.originalEvent.dataTransfer.files)
        .trigger("change");
    });
};

$(document).ready(() => $("[data-file-upload-controller]").each(FileUpload));


// Templates
const initialHTML = (field) => (
  `<h4 class="medium">Drag and drop your file here</h4>
    <label class="button primary large" for="${field}">
      Browse files
    </label>

    <div class="file-upload__errors"></div>
  `
);

const pendingHTML = () => (
  `<div class="file-upload--pending text-center">
    <h6 class="medium">Processing, please wait...</h6>
    ${progressIndicator("indeterminate")}
  </div>`
);

const errorHTML = (error) => (
  `<div class="callout cell text-center alert">
    <p>${error.message ? error.message : error}</p>
    <a href="" class="file-upload__reset">Try again.</a>
  </div>`
);

const progressHTML = (progress, filename) => (
  `<div class="file-upload--uploading text-center">
   <h6 class="medium">File(s) uploading(${filename})&hellip; <span data-file-upload-progress>${progress}%</span></h6>
    ${progressIndicator(`progress-${progress}`)}
 </div>`
);

const progressIndicator = (progress) => (
  `<svg
  xmlns="http://www.w3.org/2000/svg"
  height="48"
  width="48"
  class="progress-indicator progress-indicator--${progress}"
>
  <circle
    class="progress-indicator__background"
    stroke-width="8"
    stroke="white"
    fill="transparent"
    r="20"
    cx="24"
    cy="24"
  />

  <circle
    class="progress-indicator__progress"
    stroke-width="8"
    stroke="black"
    stroke-dasharray="126 126"
    stroke-dashoffset="126"
    fill="transparent"
    r="20"
    cx="24"
    cy="24"
  />
</svg>
  `
);

export { initialHTML, errorHTML, progressHTML, pendingHTML };
