app.views.Results = class Results extends app.View {
  static className = "_list";

  static events = { click: "onClick" };

  static routes = { after: "afterRoute" };

  constructor(sidebar, search) {
    super();
    this.sidebar = sidebar;
    this.search = search;
    this.init0(); // needs this.search
    this.refreshElements();
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
    }
  }

  init0() {
    this.addSubview((this.listFocus = new app.views.ListFocus(this.el)));
    this.addSubview((this.listSelect = new app.views.ListSelect(this.el)));

    this.search
      .on("results", (entries, flags) => this.onResults(entries, flags))
      .on("noresults", () => this.onNoResults())
      .on("clear", () => this.onClear());
  }

  onResults(entries, flags) {
    if (flags.initialResults) {
      this.listFocus?.blur();
    }
    if (flags.initialResults) {
      this.empty();
    }
    this.append(this.tmpl("sidebarResult", entries));

    if (flags.initialResults) {
      if (flags.urlSearch) {
        this.openFirst();
      } else {
        this.focusFirst();
      }
    }
  }

  onNoResults() {
    this.html(this.tmpl("sidebarNoResults"));
  }

  onClear() {
    this.empty();
  }

  focusFirst() {
    if (!app.isMobile()) {
      this.listFocus?.focusOnNextFrame(this.el.firstElementChild);
    }
  }

  openFirst() {
    this.el.firstElementChild?.click();
  }

  onDocEnabled(doc) {
    app.router.show(doc.fullPath());
    return this.sidebar.onDocEnabled();
  }

  afterRoute(route, context) {
    if (route === "entry") {
      this.listSelect.selectByHref(context.entry.fullPath());
    } else {
      this.listSelect.deselect();
    }
  }

  onClick(event) {
    let slug;
    if (event.which !== 1) {
      return;
    }
    if ((slug = $.eventTarget(event).getAttribute("data-enable"))) {
      $.stopEvent(event);
      const doc = app.disabledDocs.findBy("slug", slug);
      if (doc) {
        return app.enableDoc(doc, this.onDocEnabled.bind(this, doc), $.noop);
      }
    }
  }
};
