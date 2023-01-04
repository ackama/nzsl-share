import "jquery";
import Foundation from "foundation-sites";

$(function() {
  Foundation.MediaQuery._init();
});

$(window).on("load", function() {
  $(document).foundation();
});
