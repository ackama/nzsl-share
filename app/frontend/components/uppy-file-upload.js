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
  uppy.use(Webcam,  {
    modes: "video-only",
    countdown: true,
    locale: {
      strings: {
        pluginNameCamera: "Video recording",
        noCameraDescription: "In order to record video with your camera, please connect a camera device.",
        allowAccessDescription: "In order to record video with your camera, please allow camera access for this site."
      }
    }
  });

  uppy.use(ActiveStorageUpload, { directUploadUrl: "/rails/active_storage/direct_uploads" });

  uppy.use(Dashboard, {
    ...options.dashboard,
    inline: true,
    target: container,
    proudlyDisplayPoweredByUppy: false,
    locale: {
      strings: {
        ...options?.dashboard?.locale?.strings,
        dropPasteImportFiles: "Drop files here, or %{browseFiles}"
      }
    },
    plugins: ["Webcam"]
  });

  return uppy;
};

export default uppyFileUpload;

$(() => $("[data-controller='file-upload']").each((_idx, container) => uppyFileUpload(container)));
