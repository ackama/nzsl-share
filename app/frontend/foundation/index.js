/* global $ */
import "jquery";
import "foundation-sites";

$(document).ready(function () {
  Foundation.MediaQuery._init();
});

$(window).on("load", function () {
  $(document).foundation();
});
