$(document).ready(function() {
  $(".banner__video").click(function(e) {
    if ($(".banner__play-button").length) {
      e.preventDefault();
      videoResponse(this);
    }
  });

  $(".banner__play-button").click(function(e) {
    e.preventDefault();
    videoResponse(this.previousElementSibling);
  });

  function videoResponse(video) {
    video.paused === true ? playVideo(video) : pauseVideo(video);
  }

  function playVideo(video) {
    $(video)
        .closest(".banner__video-container")
        .children(".banner__play-button")
        .css("opacity", "0");
    $(video)[0]
        .play();
  }

  function pauseVideo(video) {
    $(video)
        .closest(".banner__video-container")
        .children(".banner__play-button")
        .css("opacity", "0");
    $(video)[0]
        .pause();
  }
});
