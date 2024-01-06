// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/pages/base

const Cls = (app.views.SupportTablesPage = class SupportTablesPage extends app.views.BasePage {
  static initClass() {
    this.events =
      {click: 'onClick'};
  }

  onClick(event) {
    if (!event.target.classList.contains('show-all')) { return; }
    $.stopEvent(event);

    let el = event.target;
    while (el.tagName !== 'TABLE') { el = el.parentNode; }
    el.classList.add('show-all');
  }
});
Cls.initClass();
