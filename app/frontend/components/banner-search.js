$(document).ready(function() {
  // Hide the header nav by default if the banner is there
  if ($(".banner").length) {
    // tablet and up
    $("#header-nav").hide();
    // mobile
    $(".header__bar .search-bar").hide();
  }
  // Show it again if we scroll past the banner
  $(document).on("scroll", function() {
    if ($(this).scrollTop() >= $("#banner-nav").position().top){
      $("#header-nav").fadeIn();
      $(".header__bar .search-bar").fadeIn();
    }
    if ($(this).scrollTop() < $("#banner-nav").position().top){
        $("#header-nav").fadeOut();
        $(".header__bar .search-bar").fadeOut();
      }
  });
});
