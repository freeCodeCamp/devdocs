/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.views.Menu = class Menu extends app.View {
  constructor(...args) {
    this.onGlobalClick = this.onGlobalClick.bind(this);
    super(...args);
  }

  static initClass() {
    this.el = '._menu';
    this.activeClass = 'active';
  
    this.events =
      {click: 'onClick'};
  }

  init() {
    $.on(document.body, 'click', this.onGlobalClick);
  }

  onClick(event) {
    const target = $.eventTarget(event);
    if (target.tagName === 'A') { target.blur(); }
  }

  onGlobalClick(event) {
    if (event.which !== 1) { return; }
    if (typeof event.target.hasAttribute === 'function' ? event.target.hasAttribute('data-toggle-menu') : undefined) {
      this.toggleClass(this.constructor.activeClass);
    } else if (this.hasClass(this.constructor.activeClass)) {
      this.removeClass(this.constructor.activeClass);
    }
  }
});
Cls.initClass();
