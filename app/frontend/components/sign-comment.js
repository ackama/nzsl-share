$(document).ready(function() {
  $("body").on("click", ".js-sign-comment-reply", function(event) {
    event.preventDefault();
    var dataId = $(this).closest("a").data("id");
    var element = document.getElementById(dataId);
    $(element).toggle();
  });

  $("body").on("click", ".js-sign-comment-reply-from-options", function(event) {
    event.preventDefault();
    var id = $(this).closest("a").data("id");
    var element = document.getElementById("sign_comment_" + id);
    $(element).toggle();
  });

  $("body").on("change", ".js-sign-comment-type", function(event) {
    event.preventDefault();
    var textComment = document.getElementById("new-text-comment");
    var videoComment = document.getElementById("new-video-comment");
    $(textComment).toggle();
    $(videoComment).toggle();
  });

  $("body").on("change", ".js-sign-comment-submit-video", function(event) {
    event.preventDefault();
    this.form.submit();
  });
});
