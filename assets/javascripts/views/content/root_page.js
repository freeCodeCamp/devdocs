// @ts-check

/**
 * The app's index: the introduction, or the splash screen once the user has
 * dismissed it.
 */
class RootPage extends app.View {
  static events = { click: "onClick" };

  /** @inheritdoc */
  init() {
    if (!this.isHidden()) {
      this.setHidden(false);
    } // reserve space in local storage
    this.render();
  }

  /** Shows whichever of the introduction and the splash belongs here. */
  render() {
    this.empty();

    const tmpl = app.isAndroidWebview()
      ? "androidWarning"
      : this.isHidden()
        ? "splash"
        : app.isMobile()
          ? "mobileIntro"
          : "intro";

    this.append(this.tmpl(tmpl));
  }

  /** Dismisses the introduction for good. */
  hideIntro() {
    this.setHidden(true);
    this.render();
  }

  /** @param {boolean} value */
  setHidden(value) {
    app.settings.set("hideIntro", value);
  }

  /** @returns {boolean} Whether the introduction has been dismissed. */
  isHidden() {
    return app.isSingleDoc() || !!app.settings.get("hideIntro");
  }

  /** @inheritdoc */
  onRoute() {}

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if ($.eventTarget(event).hasAttribute("data-hide-intro")) {
      $.stopEvent(event);
      this.hideIntro();
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.RootPage = RootPage;
