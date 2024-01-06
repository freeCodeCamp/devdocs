// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/pages/base

const Cls = (app.views.RdocPage = class RdocPage extends app.views.BasePage {
  static initClass() {
    this.events =
      {click: 'onClick'};
  }

  onClick(event) {
    if (!event.target.classList.contains('method-click-advice')) { return; }
    $.stopEvent(event);

    const source = $('.method-source-code', event.target.closest('.method-detail'));
    const isShown = source.style.display === 'block';

    source.style.display = isShown ? 'none' : 'block';
    return event.target.textContent = isShown ? 'Show source' : 'Hide source';
  }
});
Cls.initClass();
