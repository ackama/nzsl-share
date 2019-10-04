$(document).ready(function() {

  var calculate = function() {
      var characters = $("textarea[data-characters]").val().length;
      $("span[data-character-count]").text(characters)
  };

  $("body").on('keyup', "textarea[data-characters]", calculate);
});
