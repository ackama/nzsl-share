$(document).on("ajax:success", ".sign-card__votes--agree, .sign-card__votes--disagree", function() {
  const $container = $(this).parents(".js-sign-votes");
  $container.load(`${window.location} #${$container.prop("id")}  > *`);
});
