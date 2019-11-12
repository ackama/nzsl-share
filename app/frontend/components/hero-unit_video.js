$(document).ready(function() {
  $(".hero-unit__video").click(function(e) {
    if ($(".hero-unit__play-button").length) {
      e.preventDefault();
      videoResponse(this);
    }
  });

  $(".hero-unit__play-button").click(function(e) {
    e.preventDefault();
    videoResponse(this.previousElementSibling);
  });

  function videoResponse(video) {
    video.paused === true ? playVideo(video) : pauseVideo(video);
  }

  function playVideo(video) {
    $(video)
        .closest(".hero-unit__video-container")
        .children(".hero-unit__play-button")
        .css("opacity", "0");
    $(video)[0]
        .play();
  }

  function pauseVideo(video) {
    $(video)
        .closest(".hero-unit__video-container")
        .children(".hero-unit__play-button")
        .css("opacity", "0");
    $(video)[0]
        .pause();
  }
});
