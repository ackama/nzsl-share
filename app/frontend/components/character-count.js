$(document).ready(() => {
  $("body").on("keyup", ":input", ({ target }) =>
    $(`[data-character-count='${target.id}'`).text(target.value.length)
  );
});
