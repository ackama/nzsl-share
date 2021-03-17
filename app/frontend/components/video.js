// we can't do the `jquery $(document).on("ended"` because onended
// doesn't bubble up to document like click does
document.addEventListener(
  "ended",
  (event) => {
    if ($(event.target).is("video")) {
      event.target.classList.remove("video--playing");
    }
  },
  true
);

// play/pause the video underneath the video__overlay div and add the video--playing class
$(document).on("click", ".video__overlay", function() {
  const videoElement = $(this).siblings(".video").get(0);

  if (videoElement.classList.contains("video--hero")) {
    $("img.video__poster").toggle();
    videoElement.classList.toggle("video--hero--large");
  }

  videoElement.classList.toggle("video--playing");
  videoElement.paused ? videoElement.play() : videoElement.pause();

  return false;
});
