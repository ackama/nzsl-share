import Rails from "@rails/ujs";
$(document).on("upload-success", "#new_sign .file-upload", () => Rails.fire($("#new_sign").get(0), "submit"));
