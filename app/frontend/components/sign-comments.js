$(document).ready(function() {
  $("body").on("click", ".js-sign-comment-reply", function(event) {
    event.preventDefault();
    var dataId = $(this).closest("a").data("id");
    var element = document.getElementById(dataId);
    $(element).toggle();
  });

  $("body").on("change", ".js-sign-comment-folder", function(event) {
    event.preventDefault();
    var folderId = $(this).val();
    var element = document.getElementById("new-text-comment");
    $(element).children().find("input[id='sign_comment_folder_id']").val(folderId);
  });

  $("body").on("change", ".js-sign-comment-type-new", function(event) {
    event.preventDefault();
    var option = $(this).val();
    var text = document.getElementById("new-text-comment");
    var video = document.getElementById("new-video-comment");

    if (option === "video") {
      $(video).show();
      $(text).hide();
    } else {
      $(video).hide();
      $(text).show();
    }
  });

  $(".js-sign-comment-type-new").trigger("change");

  $("body").on("change", ".js-sign-comment-type-reply", function(event) {
    event.preventDefault();
    var option = $(this).val();
    var text = $(this).parent().parent().siblings().closest("div#new-text-comment-reply");
    var video = $(this).parent().parent().siblings().closest("div[id^=new-video-comment-reply]");

    if (option === "video") {
      $(video).show();
      $(text).hide();
    } else {
      $(video).hide();
      $(text).show();
    }
  });
});
