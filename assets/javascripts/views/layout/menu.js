app.views.Menu = class Menu extends app.View {
  static el = "._menu";
  static activeClass = "active";

  static events = { click: "onClick" };

  init() {
    $.on(document.body, "click", (event) => this.onGlobalClick(event));
  }

  onClick(event) {
    const target = $.eventTarget(event);
    if (target.tagName === "A") {
      target.blur();
    }
  }

  onGlobalClick(event) {
    if (event.which !== 1) {
      return;
    }
    if (
      typeof event.target.hasAttribute === "function"
        ? event.target.hasAttribute("data-toggle-menu")
        : undefined
    ) {
      this.toggleClass(this.constructor.activeClass);
    } else if (this.hasClass(this.constructor.activeClass)) {
      this.removeClass(this.constructor.activeClass);
    }
  }
};
