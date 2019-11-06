import Rails from "@rails/ujs";

$(document).ready(() => $("[data-file-upload-controller]").each(init));

const init = (controller) => {
  const $controller = $(controller);
  $controller.html(initialHTML());
};

$(document).on("drag dragstart dragend dragover dragenter dragleave drop", event => {
  event.preventDefault();
  event.stopPropagation();
})
.on("dragover dragenter", () => {
  $(".file-upload").addClass("file-upload--dragged-over");
})
.on("dragleave dragend drop", () => {
  $(".file-upload").removeClass("file-upload--dragged-over");
})
.on("drop", event => {
  let fileInput = document.querySelector("#sign_video");
  fileInput.files = event.originalEvent.dataTransfer.files;
  $(fileInput).trigger("change");
});

$(document).on("change", "input[type=file][data-direct-upload-url]", event => {
  const fileSize = event.target.files[0].size / 1024 / 1024; // in MB

  if (fileSize > 250) { // same file size as app/models/signs.rb MAXIMUM_VIDEO_FILE_SIZE
    return $("#sign-upload-errors").html(errorHTML(`Upload failed - file is too large (${Math.round(fileSize)} MB)`));
  }

  start(event);
});

$(document).on("direct-upload:initialize", event => {
  const { target, detail: { id } } = event;

  target.parentElement.children[0].remove();
  target.parentElement.children[0].remove();

  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" />
  `);
});

$(document).on("direct-upload:start", event => {
  const { id } = event.detail;
  $(`#direct-upload-${id}`).html(pendingHTML());
});

$(document).on("direct-upload:progress", event => {
  const { id, progress, file: { name: filename } } = event.detail;
  $(`#direct-upload-${id}`).html(progressHTML(Math.round(progress || 0), filename));
});

$(document).on("direct-upload:error", event => {
  const { id, error } = event.detail;
  $(`#direct-upload-${id}`).html(errorHTML(error));
});

const start = (event) => {
  Rails.fire(event.target.form, "submit");
};

const initialHTML = () => (
  `<h4 class="medium">Drag and drop your video file here</h4>
    <label class="button primary large" for="sign_video">
      Browse files
    </label>
    <input
      class="show-for-sr"
      data-direct-upload-url="/rails/active_storage/direct_uploads"
      type="file"
      name="sign[video]"
      id="sign_video"
    />
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
    <a href="">Try again.</a>
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
