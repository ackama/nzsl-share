import Uppy from "@uppy/core";
import Dashboard from "@uppy/dashboard";
import DropTarget from "@uppy/drop-target";
import Webcam from "@uppy/webcam";
import ActiveStorageUpload from "./uppy/ActiveStorageUpload";

const uppyFileUpload = (container, options = {}) => {
  const uppy = new Uppy({
    id: container.id,
    locale: {
      strings: {
        youCanOnlyUploadX: {
          0: "You can only upload %{smart_count} file at a time",
          1: "You can only upload %{smart_count} file(s) at a time",
        },
      },
    },
    ...options.uppy
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
    inline: true,
    target: container,
    proudlyDisplayPoweredByUppy: false,
    plugins: ["Webcam"],
    locale: {
      strings: {
        ...options?.dashboard?.locale?.strings,
        dropPasteImportFiles: "Drop files here, or %{browseFiles}"
      }
    },
    ...options.dashboard,
  });

  return uppy;
};

export default uppyFileUpload;

$(() =>
  $("[data-controller='file-upload']").each((_idx, container) =>
    uppyFileUpload(container)
  )
);
