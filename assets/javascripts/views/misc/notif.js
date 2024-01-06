// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.Notif = class Notif extends app.View {
  static initClass() {
    this.className = "_notif";
    this.activeClass = "_in";
    this.attributes = { role: "alert" };

    this.defaultOptions = { autoHide: 15000 };

    this.events = { click: "onClick" };
  }

  constructor(type, options) {
    super();
    this.type = type;
    this.options = $.extend({}, this.constructor.defaultOptions, options || {});
  }

  init() {
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
    const notifications = $$(`.${app.views.Notif.className}`);
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
app.views.Notif.initClass();
