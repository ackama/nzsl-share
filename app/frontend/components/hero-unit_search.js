$(document).ready(function() {
  // Hide the header nav by default if the hero-unit is there
  if ($(".hero-unit").length) {
    // tablet and up
    $("#header-nav").hide();
    // mobile
    $(".header__bar .search-bar").hide();
  }
  // Show it again if we scroll past the hero-unit
  $(document).on("scroll", function() {
    if ($(".hero-unit").length) {
      if ($(this).scrollTop() >= $("#hero-unit-nav").position().top){
        $("#header-nav").fadeIn();
        $(".header__bar .search-bar").fadeIn();
      }
      if ($(this).scrollTop() < $("#hero-unit-nav").position().top){
        $("#header-nav").fadeOut();
        $(".header__bar .search-bar").fadeOut();
      }
    }
  });
});
