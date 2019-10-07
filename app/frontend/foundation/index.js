import "jquery";
import Foundation from "foundation-sites";

$(document).ready(function() {
  Foundation.MediaQuery._init();
});

$(window).on("load", function() {
  $(document).foundation();
});
