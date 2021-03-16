/* the ended event apparently doesn't bubble up to document so this never fires */
$(document).on("ended", ".video--playing", function() {
  console.log("ON ENDED");
  $(this).get(0).classList.remove("video--playing");

  return false;
});

/* This one fires though. Perhaps its not the best way to do this though */
document.addEventListener(
  "ended",
  function(e) {
    if ($(e.target).is("video")) {
      console.log("ON ENDED 2");
      e.target.classList.remove("video--playing");
    }
  },
  true
);

$(document).on("click", ".video__overlay", function() {
  console.log("on click");
  var videoElement = $(this).siblings(".video").get(0);

  if (videoElement.classList.contains("video--hero")) {
    $("img.video__poster").toggle();
    videoElement.classList.toggle("video--hero--large");
  }

  videoElement.classList.toggle("video--playing");
  videoElement.paused ? videoElement.play() : videoElement.pause();

  return false;
});
