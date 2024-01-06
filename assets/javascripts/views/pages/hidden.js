/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.HiddenPage = class HiddenPage extends app.View {
  static initClass() {
    this.events =
      {click: 'onClick'};
  }

  constructor(el, entry) { this.onClick = this.onClick.bind(this);   this.el = el; this.entry = entry; super(...arguments); }

  init() {
    this.addSubview(this.notice = new app.views.Notice('disabledDoc'));
    this.activate();
  }

  onClick(event) {
    let link;
    if (link = $.closestLink(event.target, this.el)) {
      $.stopEvent(event);
      $.popup(link);
    }
  }
});
Cls.initClass();
