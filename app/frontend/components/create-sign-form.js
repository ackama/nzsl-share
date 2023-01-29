import Rails from "@rails/ujs";
import uppyFileUpload from "./uppy-file-upload";
$(document).on("upload-success", "#new_sign .file-upload", () => Rails.fire($("#new_sign").get(0), "submit"));

const maxFileSizeMb = 250;

const createSignController = (container) => {
  const uppy = uppyFileUpload(container);
  const maxNumberOfFiles = container.dataset.createSignContributionLimitValue;

  if (!maxNumberOfFiles) {
    throw "Required option missing: contributionLimitValue";
  }


  uppy.setOptions({
    restrictions: {
      maxFileSize: (maxFileSizeMb * 1024) * 1024,
      maxNumberOfFiles: maxNumberOfFiles,
      minNumberOfFiles: 1,
      allowedFileTypes: ["video/*", "application/mp4"]
    }
  });
};

$(() => { $("[data-controller='create-sign']").each((_idx, container) => createSignController(container)); });
