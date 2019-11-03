$(document).ready(() => {
  // Hide sign controls on Firefox and other browsers not implementing
  // pseodoclasses for controls
  $(".sign-video").attr("controls", false);
  $("<i class=\"sign-video__overlay\" alt=\"Play video\"></i>").appendTo(".sign-video-wrapper");

  const togglePlayPause = (el) => {
    el.classList.toggle("sign-video--playing");
    el.paused ? el.play() : el.pause();

    return false;
  };

  $(document).on("click", ".sign-video", e => togglePlayPause(e.target));
  $(document).on("click", ".sign-video__overlay", e => togglePlayPause(e.target.previousElementSibling));
});

