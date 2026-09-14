// @ts-check

/**
 * An entry belonging to a doc that isn't enabled: shown with a notice, and
 * with its links opened outside the app.
 */
app.views.HiddenPage = class HiddenPage extends app.View {
  static events = { click: "onClick" };

  /**
   * @param {HTMLElement} el
   * @param {any} entry
   */
  constructor(el, entry) {
    super(el);
    this.entry = entry;
  }

  /** @inheritdoc */
  init() {
    this.notice = new app.views.Notice("disabledDoc");
    this.addSubview(this.notice);
    this.activate();
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const link = $.closestLink(event.target, this.el);
    if (link) {
      $.stopEvent(event);
      $.popup(link);
    }
  }
};
