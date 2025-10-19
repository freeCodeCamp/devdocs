app.views.HiddenPage = class HiddenPage extends app.View {
  static events = { click: "onClick" };

  constructor(el, entry) {
    super(el);
    this.entry = entry;
  }

  init() {
    this.notice = new app.views.Notice("disabledDoc");
    this.addSubview(this.notice);
    this.activate();
  }

  onClick(event) {
    const link = $.closestLink(event.target, this.el);
    if (link) {
      $.stopEvent(event);
      $.popup(link);
    }
  }
};
