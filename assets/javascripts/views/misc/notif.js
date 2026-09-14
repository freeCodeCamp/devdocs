// @ts-check

/**
 * @typedef {object} NotifOptions
 * @property {number | null | false} [autoHide] How long to stay up, in
 *   milliseconds. `null` or `false` keeps it up until dismissed.
 */

/**
 * A transient message in the corner of the window.
 *
 * The type names the template to render: a Notif of type `Error` renders
 * `app.templates.notifError`. Notifications stack, each positioned below the
 * one before it.
 */
class Notif extends app.View {
  static className = "_notif";
  static activeClass = "_in";
  static attributes = { role: "alert" };

  static defaultOptions = { autoHide: 15000 };

  static events = { click: "onClick" };

  /**
   * @param {string} [type] Names the template to render. Omitted by the
   *   subclasses that render their own body.
   * @param {NotifOptions} [options]
   */
  constructor(type, options) {
    super();
    this.type = type;
    this.options = { ...this.statics().defaultOptions, ...(options || {}) };
    this.init0(); // needs this.options
    this.refreshElements();
  }

  /** Called by the constructor once `options` is set. Shows the notification. */
  init0() {
    this.show();
  }

  /** Renders and shows it, or restarts the auto-hide timer if already up. */
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
      this.addClass(this.statics().activeClass);
      if (this.options.autoHide) {
        this.timeout = this.delay(this.hide, this.options.autoHide);
      }
    }
  }

  /** Takes it back off the page. */
  hide() {
    clearTimeout(this.timeout);
    this.timeout = null;
    this.detach();
  }

  /** Renders the template named by the type. */
  render() {
    this.html(this.tmpl(`notif${this.type}`));
  }

  /** Stacks it below whichever notification is already up. */
  position() {
    const notifications = $$(`.${Notif.className}`);
    if (notifications.length) {
      const lastNotif = notifications[notifications.length - 1];
      this.el.style.top =
        lastNotif.offsetTop + lastNotif.offsetHeight + 16 + "px";
    }
  }

  /**
   * Dismisses on click, unless the click was on a link or on something with
   * a behavior of its own.
   *
   * @param {ViewMouseEvent} event
   */
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Notif = Notif;
