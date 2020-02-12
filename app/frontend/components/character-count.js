$(document).ready(() => {
  const updateCount = ({ target }) =>  target.value && $(`[data-character-count='${target.id}'`).text(target.value.length);

  $("body").on("keyup", ":input", updateCount);
  $(":input").each((_idx, el) => updateCount({ target: el }));
});
