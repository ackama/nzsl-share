import Rails from "@rails/ujs";
import React, { Component } from "react";
import { render } from "react-dom";
import { ReactComponent as ProgressIndicator } from "../images/progress-indicator.svg";

const InitialState = () => (
  <>
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
  </>
);

const PendingState = () => (
  <div className="file-upload--pending text-center">
    <h6 className="medium">Processing, please wait...</h6>
    <ProgressIndicator className="progress-indicator progress-indicator--indeterminate" />
  </div>
);

const ProgressState = ({ progress }) => (
  <div className="file-upload--uploading text-center">
    <h6 className="medium">File(s) uploading&hellip; <span data-file-upload-progress>{progress}%</span></h6>
    <ProgressIndicator className={`progress-indicator progress-indicator--progress-${progress}`} />
  </div>
);

const ErroredState = ({ error }) => (
  <div className="callout cell text-center alert">
    <p>{error.message ? error.message : error}</p>
    <a href="">Try again.</a>
  </div>
);

class DirectFileUpload extends Component {
  constructor(props) {
    super(props);
    this.state = { status: "initial" };
    this.start = this.start.bind(this);
    this.pending = this.pending.bind(this);
    this.progress = this.progress.bind(this);
    this.didError = this.didError.bind(this);
    this.container = this.props.base.parentElement;
  }
  componentDidMount() {
    $(this.container)
      .on("direct-upload:start", this.pending)
      .on("direct-upload:progress", this.progress)
      .on("direct-upload:error", this.error)
      .on("change", "input[type=file][data-direct-upload-url]", this.start);
  }
  componentWillUnmount() {
    $(this.container)
      .off("direct-upload:start", this.pending)
      .off("direct-upload:progress", this.progress)
      .off("direct-upload:error", this.didError)
      .off("change", "input[type=file][data-direct-upload-url]", this.start);
  }
  pending() {
    this.setState({ status: "pending", progress: 0 });
  }
  progress({ detail }) {
    this.setState({ status: "progress", progress: Math.round(detail.progress || 0) });
  }
  didError(event) {
    event.preventDefault();
    this.setState({ status: "errored", error: event.detail.error });
  }
  start(event) {
    Rails.fire(event.target.form, "submit");
  }
  render() {
    const { status, progress, error } = this.state;
    if (status === "initial") { return <InitialState />; }
    if (status === "pending") { return <PendingState />; }
    if (status === "progress") { return <ProgressState progress={progress} />; }
    if (status === "errored") { return <ErroredState error={error} />; }
  }
}

document.addEventListener("DOMContentLoaded", () =>
  document.querySelectorAll("[data-file-upload-controller]").forEach(el => {
    el.innerHTML = ""; // Clear the element, otherwise render() prepends
    render(<DirectFileUpload base={el} />, el);
  })
);
