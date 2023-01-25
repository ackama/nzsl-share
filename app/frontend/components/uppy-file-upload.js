import Uppy from "@uppy/core";
import Dashboard from "@uppy/dashboard";
import DropTarget from "@uppy/drop-target";
import Webcam from "@uppy/webcam";
import ActiveStorageUpload from "./uppy/ActiveStorageUpload";


const uppyFileUpload = (container, options = {}) => {
  const uppy = new Uppy({
    id: container.id,
  });

  uppy.use(DropTarget, { target: document.body });
  uppy.use(Webcam,  { modes: "video-only", countdown: true });
  uppy.use(ActiveStorageUpload, { directUploadUrl: "/rails/active_storage/direct_uploads" });

  uppy.use(Dashboard, {
    ...options.dashboard,
    inline: true,
    target: container,
    proudlyDisplayPoweredByUppy: false,
    plugins: ["Webcam"]
  });

  return uppy;
};

export default uppyFileUpload;

$(document).on("turbolinks:load", () => $("[data-controller='file-upload']").each((_idx, container) => uppyFileUpload(container)));
