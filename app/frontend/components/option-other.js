$(document).ready(() => {
  $("[data-toggle-other]").each((_idx, toggle) => {
    const $input = $(toggle.dataset.toggleOther);
    const $others = $(`input[name='${toggle.name}']`);

    $others.on("change", function() {
      const vals = $others.filter(":checked").map(function() { return this.value; }).get();
      $input.prop("disabled", !vals.includes(toggle.value));
    });

    $(toggle).trigger("change");
  });
});