let switchNavMenuItem = (menuItems) => {
  var current = location.pathname;

  $.each(menuItems, (index, item) => {
      $(item).parent().removeClass("is-active");

      if (current === $(item).attr("href")){
          $(item).parent().addClass("is-active");
      }
  });
};

$(document).ready(() => {
  switchNavMenuItem($(".menu li a"));
});
