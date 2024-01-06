app.views.RootPage = class RootPage extends app.View {
  static events = { click: "onClick" };

  init() {
    if (!this.isHidden()) {
      this.setHidden(false);
    } // reserve space in local storage
    this.render();
  }

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

  hideIntro() {
    this.setHidden(true);
    this.render();
  }

  setHidden(value) {
    app.settings.set("hideIntro", value);
  }

  isHidden() {
    return app.isSingleDoc() || app.settings.get("hideIntro");
  }

  onRoute() {}

  onClick(event) {
    if ($.eventTarget(event).hasAttribute("data-hide-intro")) {
      $.stopEvent(event);
      this.hideIntro();
    }
  }
};
