$(() => {
  $("input:radio[data-toggle-truthy]").each(function() {
    const $all = $(`input[name='${this.name}']`);
    const $target = $(this.dataset.toggleTruthy);
    if (!$target.length) { return; }

    $all.on("change", function() {
      const visible = $(this).val() === "true";

      $target.toggle(visible)
            .find("input")
            .prop("required", visible)
            .prop("disabled", !visible);
    });

    $all.filter(":checked").trigger("change");
  });
});
