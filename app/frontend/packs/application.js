// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require.context('../images', true);
import Rails from '@rails/ujs';
require('@rails/activestorage').start();
Rails.start();

import 'foundation';
import '../application.scss';
import '../components/header';
import '../components/character-count';
import '../components/folder-membership';
import '../components/hero-unit_search';
import '../components/option-other';
import '../components/video.js';
import '../components/toggle-truthy';
import 'chosen-js/chosen.jquery';
import '../components/chosen-topics';
import '../components/sign-comments';
