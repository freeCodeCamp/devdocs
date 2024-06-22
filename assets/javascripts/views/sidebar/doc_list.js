app.views.DocList = class DocList extends app.View {
  static className = "_list";
  static attributes = { role: "navigation" };

  static events = {
    open: "onOpen",
    close: "onClose",
    click: "onClick",
  };

  static routes = { after: "afterRoute" };

  static elements = {
    disabledTitle: "._list-title",
    disabledList: "._disabled-list",
  };

  init() {
    this.lists = {};

    this.addSubview((this.listFocus = new app.views.ListFocus(this.el)));
    this.addSubview((this.listFold = new app.views.ListFold(this.el)));
    this.addSubview((this.listSelect = new app.views.ListSelect(this.el)));

    app.on("ready", () => this.render());
  }

  activate() {
    if (super.activate(...arguments)) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.activate();
      }
      this.listSelect.selectCurrent();
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.deactivate();
      }
    }
  }

  render() {
    let html = "";
    for (var doc of app.docs.all()) {
      html += this.tmpl("sidebarDoc", doc, {
        fullName: app.docs.countAllBy("name", doc.name) > 1,
      });
    }
    this.html(html);
    if (!app.isSingleDoc() && app.disabledDocs.size() !== 0) {
      this.renderDisabled();
    }
  }

  renderDisabled() {
    this.append(
      this.tmpl("sidebarDisabled", { count: app.disabledDocs.size() }),
    );
    this.refreshElements();
    this.renderDisabledList();
  }

  renderDisabledList() {
    if (app.settings.get("hideDisabled")) {
      this.removeDisabledList();
    } else {
      this.appendDisabledList();
    }
  }

  appendDisabledList() {
    let doc;
    let html = "";
    const docs = [].concat(...(app.disabledDocs.all() || []));

    while ((doc = docs.shift())) {
      if (doc.version != null) {
        var versions = "";
        while (true) {
          versions += this.tmpl("sidebarDoc", doc, { disabled: true });
          if (docs[0]?.name !== doc.name) {
            break;
          }
          doc = docs.shift();
        }
        html += this.tmpl("sidebarDisabledVersionedDoc", doc, versions);
      } else {
        html += this.tmpl("sidebarDoc", doc, { disabled: true });
      }
    }

    this.append(this.tmpl("sidebarDisabledList", html));
    this.disabledTitle.classList.add("open-title");
    this.refreshElements();
  }

  removeDisabledList() {
    if (this.disabledList) {
      $.remove(this.disabledList);
    }
    this.disabledTitle.classList.remove("open-title");
    this.refreshElements();
  }

  reset(options) {
    if (options == null) {
      options = {};
    }
    this.listSelect.deselect();
    if (this.listFocus != null) {
      this.listFocus.blur();
    }
    this.listFold.reset();
    if (options.revealCurrent || app.isSingleDoc()) {
      this.revealCurrent();
    }
  }

  onOpen(event) {
    $.stopEvent(event);
    const doc = app.docs.findBy("slug", event.target.getAttribute("data-slug"));

    if (doc && !this.lists[doc.slug]) {
      this.lists[doc.slug] = doc.types.isEmpty()
        ? new app.views.EntryList(doc.entries.all())
        : new app.views.TypeList(doc);
      $.after(event.target, this.lists[doc.slug].el);
    }
  }

  onClose(event) {
    $.stopEvent(event);
    const doc = app.docs.findBy("slug", event.target.getAttribute("data-slug"));

    if (doc && this.lists[doc.slug]) {
      this.lists[doc.slug].detach();
      delete this.lists[doc.slug];
    }
  }

  select(model) {
    this.listSelect.selectByHref(model?.fullPath());
  }

  reveal(model) {
    this.openDoc(model.doc);
    if (model.type) {
      this.openType(model.getType());
    }
    this.focus(model);
    this.paginateTo(model);
    this.scrollTo(model);
  }

  focus(model) {
    if (this.listFocus != null) {
      this.listFocus.focus(this.find(`a[href='${model.fullPath()}']`));
    }
  }

  revealCurrent() {
    let model;
    if ((model = app.router.context.type || app.router.context.entry)) {
      this.reveal(model);
      this.select(model);
    }
  }

  openDoc(doc) {
    if (app.disabledDocs.contains(doc) && doc.version) {
      this.listFold.open(
        this.find(`[data-slug='${doc.slug_without_version}']`),
      );
    }
    this.listFold.open(this.find(`[data-slug='${doc.slug}']`));
  }

  closeDoc(doc) {
    this.listFold.close(this.find(`[data-slug='${doc.slug}']`));
  }

  openType(type) {
    this.listFold.open(
      this.lists[type.doc.slug].find(`[data-slug='${type.slug}']`),
    );
  }

  paginateTo(model) {
    if (this.lists[model.doc.slug] != null) {
      this.lists[model.doc.slug].paginateTo(model);
    }
  }

  scrollTo(model) {
    $.scrollTo(this.find(`a[href='${model.fullPath()}']`), null, "top", {
      margin: app.isMobile() ? 48 : 0,
    });
  }

  toggleDisabled() {
    if (this.disabledTitle.classList.contains("open-title")) {
      this.removeDisabledList();
      app.settings.set("hideDisabled", true);
    } else {
      this.appendDisabledList();
      app.settings.set("hideDisabled", false);
    }
  }

  onClick(event) {
    let slug;
    const target = $.eventTarget(event);
    if (
      this.disabledTitle &&
      $.hasChild(this.disabledTitle, target) &&
      target.tagName !== "A"
    ) {
      $.stopEvent(event);
      this.toggleDisabled();
    } else if ((slug = target.getAttribute("data-enable"))) {
      $.stopEvent(event);
      const doc = app.disabledDocs.findBy("slug", slug);
      if (doc) {
        this.onEnabled = this.onEnabled.bind(this);
        app.enableDoc(doc, this.onEnabled, this.onEnabled);
      }
    }
  }

  onEnabled() {
    this.reset();
    this.render();
  }

  afterRoute(route, context) {
    if (context.init) {
      if (this.activated) {
        this.reset({ revealCurrent: true });
      }
    } else {
      this.select(context.type || context.entry);
    }
  }
};
