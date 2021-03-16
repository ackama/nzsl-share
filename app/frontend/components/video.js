// eslint-disable-next-line no-undef
togglePlayPause = function(el) {
  if (el.classList.contains("video--hero")) {
    $("img.video__poster").toggle();
    el.classList.toggle("video--hero--large");
  }

  el.classList.toggle("video--playing");
  el.paused ? el.play() : el.pause();

  return false;
};
