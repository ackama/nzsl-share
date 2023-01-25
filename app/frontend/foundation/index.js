import Foundation from "foundation-sites";

$(document).ready(function() {
  Foundation.MediaQuery._init();
});

$(document).on("turbolinks:load", function() {
  $(function(){ $(document).foundation(); });
});
