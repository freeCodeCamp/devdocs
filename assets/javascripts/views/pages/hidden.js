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
    let link;
    if ((link = $.closestLink(event.target, this.el))) {
      $.stopEvent(event);
      $.popup(link);
    }
  }
};
