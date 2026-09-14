// @ts-check

/** The header menu, opened by the toggle and closed by a click anywhere else. */
class Menu extends app.View {
  static el = "._menu";
  static activeClass = "active";

  static events = { click: "onClick" };

  /** @inheritdoc */
  init() {
    $.on(document.body, "click", (event) => this.onGlobalClick(event));
  }

  /**
   * Drops the focus ring after following a link.
   *
   * @param {ViewMouseEvent} event
   */
  onClick(event) {
    const target = $.eventTarget(event);
    if (target.tagName === "A") {
      target.blur();
    }
  }

  /** @param {ViewMouseEvent} event */
  onGlobalClick(event) {
    if (event.which !== 1) {
      return;
    }
    if (
      typeof event.target.hasAttribute === "function"
        ? event.target.hasAttribute("data-toggle-menu")
        : undefined
    ) {
      this.toggleClass(this.statics().activeClass);
    } else if (this.hasClass(this.statics().activeClass)) {
      this.removeClass(this.statics().activeClass);
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Menu = Menu;
