var $modal = $('#new-folder');


$(() => $("a[data-remote]").on("ajax:success", event => $('#new-folder').foundation('open')));

