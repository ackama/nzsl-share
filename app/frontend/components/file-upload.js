import Rails from "@rails/ujs";
// import React, { Component } from "react";
// import { render } from "react-dom";
// import { ReactComponent as ProgressIndicator } from "../images/progress-indicator.svg";

// const InitialState = () => (
//   <>
//     <h4 className="medium">Drag and drop your video file here</h4>
//     <label className="button primary large" htmlFor="sign_video">
//       Browse files
//     </label>
//     <input
//       className="show-for-sr"
//       data-direct-upload-url="/rails/active_storage/direct_uploads"
//       type="file"
//       name="sign[video]"
//       id="sign_video"
//     />
//   </>
// );

// const PendingState = () => {
//   setTimeout(function() { debugger }, 2000);
//   return (
//   <div className="file-upload--pending text-center">
//     <h6 className="medium">Processing, please wait...</h6>
//     <ProgressIndicator className="progress-indicator progress-indicator--indeterminate" />
//   </div>
//   );
// };

// const ProgressState = ({ progress }) => {
//   setTimeout(function() { debugger }, 2000);
//   return (
//   <div className="file-upload--uploading text-center">
//     <h6 className="medium">File(s) uploading&hellip; <span data-file-upload-progress>{progress}%</span></h6>
//     <ProgressIndicator className={`progress-indicator progress-indicator--progress-${progress}`} />
//   </div>
//   );
// };

// const ErroredState = ({ error }) => (
//   <div className="callout cell text-center alert">
//     <p>{error.message ? error.message : error}</p>
//     <a href="">Try again.</a>
//   </div>
// );

// class DirectFileUpload extends Component {
//   constructor(props) {
//     super(props);
//     this.state = { status: "initial" };
//     this.start = this.start.bind(this);
//     this.pending = this.pending.bind(this);
//     this.progress = this.progress.bind(this);
//     this.didError = this.didError.bind(this);
//     this.container = this.props.base.parentElement;
//   }
//   componentDidMount() {
//     $(this.container)
//       .on("direct-upload:start", this.pending)
//       .on("direct-upload:progress", this.progress)
//       .on("direct-upload:error", this.error)
//       .on("change", "input[type=file][data-direct-upload-url]", this.start);
//   }
//   componentWillUnmount() {
//     $(this.container)
//       .off("direct-upload:start", this.pending)
//       .off("direct-upload:progress", this.progress)
//       .off("direct-upload:error", this.didError)
//       .off("change", "input[type=file][data-direct-upload-url]", this.start);
//   }
//   pending() {
//     this.setState({ status: "pending", progress: 0 });
//   }
//   progress({ detail }) {
//     this.setState({ status: "progress", progress: Math.round(detail.progress || 0) });
//   }
//   didError(event) {
//     event.preventDefault();
//     this.setState({ status: "errored", error: event.detail.error });
//   }
//   start(event) {
//     Rails.fire(event.target.form, "submit");
//   }
//   render() {
//     const { status, progress, error } = this.state;
//     if (status === "initial") { return <InitialState />; }
//     if (status === "pending") { return <PendingState />; }
//     if (status === "progress") { return <ProgressState progress={progress} />; }
//     if (status === "errored") { return <ErroredState error={error} />; }
//   }
// }

// document.addEventListener("DOMContentLoaded", () =>
//   document.querySelectorAll("[data-file-upload-controller]").forEach(el => {
//     el.innerHTML = ""; // Clear the element, otherwise render() prepends
//     render(<DirectFileUpload base={el} />, el);
//   })
// );

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event;
  const { id, file } = detail;
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename">${file.name}</span>
    </div>
  `);
});

addEventListener("direct-upload:start", event => {
  const { id } = event.detail;
  $(`#direct-upload-${id}`).html(pendingHTML());
});

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail;
  $(`#direct-upload-${id}`).html(progressHTML(Math.round(progress || 0)));
});

addEventListener("direct-upload:error", event => {
  event.preventDefault();
  const { id, error } = event.detail;
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.add("direct-upload--error");
  element.setAttribute("title", error);
});

$(document).on("change", "input[type=file][data-direct-upload-url]", () =>
   start(event)
);

$(document).on("DOMContentLoaded", () => {
  $(".file-upload").html(initialHTML());

  $(document).on("change", "input[type=file][data-direct-upload-url]", () =>
   start(event)
  );
});

const start = (event) => {
  Rails.fire(event.target.form, "submit");
};

const initialHTML = () => (
  `<div>
    <h4 className="medium">Drag and drop your video file here</h4>
      <label className="button primary large" htmlFor="sign_video">
        Browse files
      </label>
      <input
        className="show-for-sr"
        data-direct-upload-url="/rails/active_storage/direct_uploads"
        type="file"
        name="sign[video]"
        id="sign_video"
      />
  </div>`
);

const pendingHTML = () => (
  `<div className="file-upload--pending text-center">
    <h6 className="medium">Processing, please wait...</h6>
    ${progressIndicator("indeterminate")}
  </div>`
);


// const errorHTML = (error) => (
//   `<div className="callout cell text-center alert">
//     <p>${error.message ? error.message : error}</p>
//     <a href="">Try again.</a>
//   </div>`
// );

const progressHTML = (progress) => (
  `<div className="file-upload--uploading text-center">
   <h6 className="medium">File(s) uploading&hellip; <span data-file-upload-progress>${progress}%</span></h6>
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