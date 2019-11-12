$(document).ready(() => {
  // Hide sign controls on Firefox and other browsers not implementing
  // pseodoclasses for controls
  $(".sign-video").attr("controls", false);
  $(".hero-unit__video").attr("controls", false);
  $("<i class=\"sign-video__overlay\" alt=\"Play video\"></i>").appendTo(".sign-video-wrapper");

  const togglePlayPause = (el) => {
    if ($(el).hasClass("hero-unit__video")) {
      $(el.nextElementSibling).toggleClass("hide");
    } else {
      el.classList.toggle("sign-video--playing");
    }

    el.paused ? el.play() : el.pause();

    return false;
  };

  $(document).on("click", ".sign-video", e => togglePlayPause(e.target));
  $(document).on("click", ".hero-unit__video", e => togglePlayPause(e.target));
  $(document).on("click", ".sign-video__overlay", e => togglePlayPause(e.target.previousElementSibling));
  $(document).on("click", ".hero-unit__play-button", () => togglePlayPause($(".hero-unit__video")[0]));
});

