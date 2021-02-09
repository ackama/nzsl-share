// I added this line to pass eslint
import jQuery from "jquery";

var selector = ".js-sign-video-container";
var nextrun = 2000;

function refresh() {
  var $currentContainer = jQuery(selector);
  var $currentVideo = $currentContainer.find(".video");
  jQuery
    .ajax({
      url: window.location,
      dataType: "html",
    })
    .done(function(responseText) {
      var $newVideoContainer = jQuery("<div>")
        .append(jQuery.parseHTML(responseText))
        .find(selector);
      var $newVideo = $newVideoContainer.find(".video");

      // Only refresh the HTML of the element if the classes of the video have changed
      if (
        $newVideo.get(0) &&
        $newVideo.get(0).classList.value !==
          $currentVideo.get(0).classList.value
      ) {
        $currentContainer.html($newVideoContainer.html());
      }

      // Kick off another poll if the video isn't processed yet
      if (!$newVideo.hasClass("has-video")) {
        setTimeout(refresh, nextrun);
      }
    });
}

// refresh immediately to check if the video has been processed
refresh();
