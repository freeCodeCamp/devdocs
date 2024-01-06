app.views.Document = class Document extends app.View {
  static el = document;

  static events = { visibilitychange: "onVisibilityChange" };

  static shortcuts = {
    help: "onHelp",
    preferences: "onPreferences",
    escape: "onEscape",
    superLeft: "onBack",
    superRight: "onForward",
  };

  static routes = { after: "afterRoute" };

  init() {
    this.menu = new app.views.Menu();
    this.sidebar = new app.views.Sidebar();
    this.addSubview(this.menu, this.addSubview(this.sidebar));
    if (app.views.Resizer.isSupported()) {
      this.resizer = new app.views.Resizer();
      this.addSubview(this.resizer);
    }
    this.content = new app.views.Content();
    this.addSubview(this.content);
    if (!app.isSingleDoc() && !app.isMobile()) {
      this.path = new app.views.Path();
      this.addSubview(this.path);
    }
    if (!app.isSingleDoc()) {
      this.settings = new app.views.Settings();
    }

    $.on(document.body, "click", this.onClick);

    this.activate();
  }

  setTitle(title) {
    return (this.el.title = title
      ? `${title} — DevDocs`
      : "DevDocs API Documentation");
  }

  afterRoute(route) {
    if (route === "settings") {
      if (this.settings != null) {
        this.settings.activate();
      }
    } else {
      if (this.settings != null) {
        this.settings.deactivate();
      }
    }
  }

  onVisibilityChange() {
    if (this.el.visibilityState !== "visible") {
      return;
    }
    this.delay(() => {
      if (app.isMobile() !== app.views.Mobile.detect()) {
        location.reload();
      }
    }, 300);
  }

  onHelp() {
    app.router.show("/help#shortcuts");
  }

  onPreferences() {
    app.router.show("/settings");
  }

  onEscape() {
    const path =
      !app.isSingleDoc() || location.pathname === app.doc.fullPath()
        ? "/"
        : app.doc.fullPath();

    app.router.show(path);
  }

  onBack() {
    history.back();
  }

  onForward() {
    history.forward();
  }

  onClick(event) {
    const target = $.eventTarget(event);
    if (!target.hasAttribute("data-behavior")) {
      return;
    }
    $.stopEvent(event);
    switch (target.getAttribute("data-behavior")) {
      case "back":
        history.back();
        break;
      case "reload":
        window.location.reload();
        break;
      case "reboot":
        app.reboot();
        break;
      case "hard-reload":
        app.reload();
        break;
      case "reset":
        if (confirm("Are you sure you want to reset DevDocs?")) {
          app.reset();
        }
        break;
      case "accept-analytics":
        Cookies.set("analyticsConsent", "1", { expires: 1e8 }) && app.reboot();
        break;
      case "decline-analytics":
        Cookies.set("analyticsConsent", "0", { expires: 1e8 }) && app.reboot();
        break;
    }
  }
};
