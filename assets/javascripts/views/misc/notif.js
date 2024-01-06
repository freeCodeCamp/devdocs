app.views.Notif = class Notif extends app.View {
  static className = "_notif";
  static activeClass = "_in";
  static attributes = { role: "alert" };

  static defaultOptions = { autoHide: 15000 };

  static events = { click: "onClick" };

  constructor(type, options) {
    super();
    this.type = type;
    this.options = { ...this.constructor.defaultOptions, ...(options || {}) };
    this.init0(); // needs this.options
    this.refreshElements();
  }

  init0() {
    this.show();
  }

  show() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = this.delay(this.hide, this.options.autoHide);
    } else {
      this.render();
      this.position();
      this.activate();
      this.appendTo(document.body);
      this.el.offsetWidth; // force reflow
      this.addClass(this.constructor.activeClass);
      if (this.options.autoHide) {
        this.timeout = this.delay(this.hide, this.options.autoHide);
      }
    }
  }

  hide() {
    clearTimeout(this.timeout);
    this.timeout = null;
    this.detach();
  }

  render() {
    this.html(this.tmpl(`notif${this.type}`));
  }

  position() {
    const notifications = $$(`.${Notif.className}`);
    if (notifications.length) {
      const lastNotif = notifications[notifications.length - 1];
      this.el.style.top =
        lastNotif.offsetTop + lastNotif.offsetHeight + 16 + "px";
    }
  }

  onClick(event) {
    if (event.which !== 1) {
      return;
    }
    const target = $.eventTarget(event);
    if (target.hasAttribute("data-behavior")) {
      return;
    }
    if (target.tagName !== "A" || target.classList.contains("_notif-close")) {
      $.stopEvent(event);
      this.hide();
    }
  }
};
