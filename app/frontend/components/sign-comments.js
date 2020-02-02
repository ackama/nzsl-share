$(document).ready(function() {
  $("body").on("click", ".js-sign-comment-reply", function(event) {
    event.preventDefault();
    var dataId = $(this).closest("a").data("id");
    var element = document.getElementById(dataId);
    $(element).toggle();
  });

  $("body").on("change", ".js-sign-comment-type", function(event) {
    event.preventDefault();

    var option = $(this).children("option:selected").val();
    var text = document.getElementById("new-text-comment");
    var video = document.getElementById("new-video-comment");

    if (option === "video") {
      $(video).show();
      $(text).hide();
      $("#sign_comment_video_type").val("video");
      $("#sign_comment_text_type").val("video");
    } else {
      $(video).hide();
      $(text).show();
      $("#sign_comment_video_type").val("text");
      $("#sign_comment_text_type").val("text");
    }
  });
});
