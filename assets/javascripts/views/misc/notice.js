// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.Notice = class Notice extends app.View {
  static initClass() {
    this.className = "_notice";
    this.attributes = { role: "alert" };
  }

  constructor(type, ...rest) {
    super();
    this.type = type;
    [...this.args] = Array.from(rest);
  }

  init() {
    this.activate();
  }

  activate() {
    if (super.activate(...arguments)) {
      this.show();
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.hide();
    }
  }

  show() {
    this.html(this.tmpl(`${this.type}Notice`, ...Array.from(this.args)));
    this.prependTo(app.el);
  }

  hide() {
    $.remove(this.el);
  }
};
app.views.Notice.initClass();
