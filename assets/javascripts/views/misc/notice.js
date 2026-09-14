// @ts-check

/**
 * A persistent bar above the content, e.g. to say that the doc being read is
 * disabled. The type names the template to render: a Notice of type
 * `singleDoc` renders `app.templates.singleDocNotice`.
 */
app.views.Notice = class Notice extends app.View {
  static className = "_notice";
  static attributes = { role: "alert" };

  /**
   * @param {string} type Names the template to render.
   * @param {...any} args Passed on to the template.
   */
  constructor(type, ...args) {
    super();
    this.type = type;
    this.args = args || [];
    this.init0(); // needs this.args
    this.refreshElements();
  }

  /** Called by the constructor once `args` is set. */
  init0() {
    this.activate();
  }

  activate() {
    if (super.activate()) {
      this.show();
    }
  }

  deactivate() {
    if (super.deactivate()) {
      this.hide();
    }
  }

  /** Renders the notice and puts it above the content. */
  show() {
    this.html(this.tmpl(`${this.type}Notice`, ...this.args));
    this.prependTo(app.el);
  }

  /** Takes it off the page. */
  hide() {
    $.remove(this.el);
  }
};
