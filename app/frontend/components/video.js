$(document).ready(() => {
  // Hide sign controls on Firefox and other browsers not implementing
  // pseodoclasses for controls
  $(".video").attr("controls", false);
  $("<i class=\"video__overlay\" alt=\"Play video\"></i>").appendTo(".video-wrapper[data-overlay]");

  const togglePlayPause = (el) => {
    el.classList.toggle("video--playing");
    el.paused ? el.play() : el.pause();

    return false;
  };

  $(document).on("click", ".video", e => togglePlayPause(e.target));
  $(document).on("click", ".video__overlay", e => togglePlayPause(e.target.previousElementSibling));
});

