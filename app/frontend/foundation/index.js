import "jquery";
import Foundation from "foundation-sites";

$(document).on("turbo:load turbo:frame-render", function() {
  Foundation.MediaQuery._init();
  $(document).foundation();
});
