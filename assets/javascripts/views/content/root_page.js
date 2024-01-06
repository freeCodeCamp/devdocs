// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.RootPage = class RootPage extends app.View {
  constructor(...args) {
    this.onClick = this.onClick.bind(this);
    super(...args);
  }

  static initClass() {
    this.events =
      {click: 'onClick'};
  }

  init() {
    if (!this.isHidden()) { this.setHidden(false); } // reserve space in local storage
    this.render();
  }

  render() {
    this.empty();

    const tmpl = app.isAndroidWebview() ?
      'androidWarning'
    : this.isHidden() ?
      'splash'
    : app.isMobile() ?
      'mobileIntro'
    :
      'intro';

    this.append(this.tmpl(tmpl));
  }

  hideIntro() {
    this.setHidden(true);
    this.render();
  }

  setHidden(value) {
    app.settings.set('hideIntro', value);
  }

  isHidden() {
    return app.isSingleDoc() || app.settings.get('hideIntro');
  }

  onRoute() {}

  onClick(event) {
    if ($.eventTarget(event).hasAttribute('data-hide-intro')) {
      $.stopEvent(event);
      this.hideIntro();
    }
  }
});
Cls.initClass();
