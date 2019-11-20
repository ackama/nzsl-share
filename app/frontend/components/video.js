const togglePlayPause = (el) => {
  el.classList.toggle("video--playing");
  el.paused ? el.play() : el.pause();

  return false;
};

$(document).ready(() => {
  $(".video").each(function() {
    const $vid = $(this);

    // Hide sign controls on Firefox and other browsers not implementing
    // pseodoclasses for controls
    $vid.attr("controls", false);
    $("<i class=\"video__overlay\" alt=\"Play video\"></i>").appendTo($vid.parents(".video-wrapper[data-overlay]"));
    $("<i class=\"video__overlay video__overlay--hero\" alt=\"Play video\"></i>").appendTo($vid.parents(".video-wrapper--hero[data-overlay]"));

    $vid
      .on("click", () => togglePlayPause($vid.get(0)))
      .on("ended", () => $vid.get(0).classList.remove("video--playing"));
    $vid.siblings(".video__overlay").on("click", () => togglePlayPause($vid.get(0)));
  });
});

