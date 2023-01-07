/* eslint no-console:0 */
/* global require */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'contributions' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


require.context("../images", true);

// Rails is loaded to set up CSRF tokens with jQuery.
// Because of how webpack scopes imports, this must be done
// once per pack.
// eslint-disable-next-line no-unused-vars
import Rails from "@rails/ujs";

import "../components/file-upload";
import "../components/video-comment";
