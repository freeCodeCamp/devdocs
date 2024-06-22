app.views.Notice = class Notice extends app.View {
  static className = "_notice";
  static attributes = { role: "alert" };

  constructor(type, ...args) {
    super();
    this.type = type;
    this.args = args || [];
    this.init0(); // needs this.args
    this.refreshElements();
  }

  init0() {
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
    this.html(this.tmpl(`${this.type}Notice`, ...this.args));
    this.prependTo(app.el);
  }

  hide() {
    $.remove(this.el);
  }
};
