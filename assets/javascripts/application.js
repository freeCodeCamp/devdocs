// @ts-check

//= require_tree ./vendor

//= require lib/license
//= require_tree ./lib

//= require app/app
//= require app/config
//= require_tree ./app

//= require collections/collection
//= require_tree ./collections

//= require models/model
//= require_tree ./models

//= require views/view
//= require_tree ./views

//= require_tree ./templates

//= link_tree ../images/sprites

//= require tracking

/**
 * Boots the app once the document is ready, retrying until the body exists —
 * the bundle is loaded in the head, so it can run before the body is parsed.
 */
var init = function () {
  document.removeEventListener("DOMContentLoaded", init, false);

  if (document.body) {
    return app.init();
  } else {
    return setTimeout(init, 42);
  }
};

document.addEventListener("DOMContentLoaded", init, false);
