// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.ListSelect = class ListSelect extends app.View {
  static initClass() {
    this.activeClass = "active";

    this.events = { click: "onClick" };
  }

  constructor(el) {
    this.onClick = this.onClick.bind(this);
    this.el = el;
    super(...arguments);
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.deselect();
    }
  }

  select(el) {
    this.deselect();
    if (el) {
      el.classList.add(this.constructor.activeClass);
      $.trigger(el, "select");
    }
  }

  deselect() {
    let selection;
    if ((selection = this.getSelection())) {
      selection.classList.remove(this.constructor.activeClass);
      $.trigger(selection, "deselect");
    }
  }

  selectByHref(href) {
    if (
      __guard__(this.getSelection(), (x) => x.getAttribute("href")) !== href
    ) {
      this.select(this.find(`a[href='${href}']`));
    }
  }

  selectCurrent() {
    this.selectByHref(location.pathname + location.hash);
  }

  getSelection() {
    return this.findByClass(this.constructor.activeClass);
  }

  onClick(event) {
    if (event.which !== 1 || event.metaKey || event.ctrlKey) {
      return;
    }
    const target = $.eventTarget(event);
    if (target.tagName === "A") {
      this.select(target);
    }
  }
};
app.views.ListSelect.initClass();

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}
