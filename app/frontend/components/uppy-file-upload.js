import Uppy from "@uppy/core";
import Dashboard from "@uppy/dashboard";
import DropTarget from "@uppy/drop-target";
import Webcam from "@uppy/webcam";


const uppyFileUpload = (container) => {
  const uppy = new Uppy({
    id: container.id
  });


  uppy.use(DropTarget, { target: document.body });
  uppy.use(Webcam,  { modes: "video-only", countdown: true });

  uppy.use(Dashboard, {
    inline: true,
    target: container,
    proudlyDisplayPoweredByUppy: false,
    plugins: ["Webcam"]
  });
};


$(() => $("[data-controller='file-upload']").each((_idx, container) => uppyFileUpload(container)));
