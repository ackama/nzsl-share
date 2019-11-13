const togglePlayPause = (el) => {
  console.log(el);
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

    $vid.on("click", () => togglePlayPause($vid.get(0)));
    $vid.siblings(".video__overlay").on("click", () => togglePlayPause($vid.get(0)));
  });
});

