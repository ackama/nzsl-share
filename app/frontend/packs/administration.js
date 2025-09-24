// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'administration' %> to the appropriate
// layout file, like app/views/layouts/admin/application.html.erb

require.context('../images', true);
require('@rails/activestorage').start();

import 'foundation';
import '../application.scss';
import '../components/header';
import '@selectize/selectize/dist/js/selectize.min.js';
