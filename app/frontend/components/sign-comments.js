$(document).ready(function() {
  $("body").on("click", ".js-sign-comment-reply", function(event) {
    event.preventDefault();
    var dataId = $(this).closest("a").data("id");
    var element = document.getElementById(dataId);
    $(element).toggle();
  });
});