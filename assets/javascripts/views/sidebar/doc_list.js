// @ts-check

/**
 * The list of docs in the sidebar.
 *
 * A doc's types are only built when it is expanded, and thrown away when it is
 * collapsed. Disabled docs are listed separately underneath, behind a heading
 * that can be folded away.
 */
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

  /** @inheritdoc */
  init() {
    this.lists = {};

    this.addSubview((this.listFocus = new app.views.ListFocus(this.el)));
    this.addSubview((this.listFold = new app.views.ListFold(this.el)));
    this.addSubview((this.listSelect = new app.views.ListSelect(this.el)));

    app.on("ready", () => this.render());
  }

  /** Also activates the type lists and marks the entry being read. */
  activate() {
    if (super.activate()) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.activate();
      }
      this.listSelect.selectCurrent();
    }
  }

  /** Also deactivates the type lists. */
  deactivate() {
    if (super.deactivate()) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.deactivate();
      }
    }
  }

  /** Rebuilds the list from the enabled docs. */
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

  /** Adds the heading for the disabled docs. */
  renderDisabled() {
    this.append(
      this.tmpl("sidebarDisabled", { count: app.disabledDocs.size() })
    );
    this.refreshElements();
    this.renderDisabledList();
  }

  /** Builds the disabled docs, grouping versions of the same doc. */
  renderDisabledList() {
    if (app.settings.get("hideDisabled")) {
      this.removeDisabledList();
    } else {
      this.appendDisabledList();
    }
  }

  /** Shows the disabled docs under their heading. */
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

  /** Hides the disabled docs again. */
  removeDisabledList() {
    if (this.disabledList) {
      $.remove(this.disabledList);
    }
    this.disabledTitle.classList.remove("open-title");
    this.refreshElements();
  }

  /**
   * Collapses everything and returns to the selected entry.
   *
   * @param {{ revealCurrent?: boolean }} [options]
   */
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

  /**
   * Builds the expanded doc's type list.
   *
   * @param {ViewEvent} event
   */
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

  /**
   * Throws away the collapsed doc's type list.
   *
   * @param {ViewEvent} event
   */
  onClose(event) {
    $.stopEvent(event);
    const doc = app.docs.findBy("slug", event.target.getAttribute("data-slug"));

    if (doc && this.lists[doc.slug]) {
      this.lists[doc.slug].detach();
      delete this.lists[doc.slug];
    }
  }

  /** @param {any} model The entry to mark as being read. */
  select(model) {
    this.listSelect.selectByHref(model?.fullPath());
  }

  /** @param {any} model The entry to expand down to and scroll into view. */
  reveal(model) {
    this.openDoc(model.doc);
    if (model.type) {
      this.openType(model.getType());
    }
    this.focus(model);
    this.paginateTo(model);
    this.scrollTo(model);
  }

  /** @param {any} model The entry to move the keyboard focus to. */
  focus(model) {
    if (this.listFocus != null) {
      this.listFocus.focus(this.find(`a[href='${model.fullPath()}']`));
    }
  }

  /** Expands down to the entry being read. */
  revealCurrent() {
    const model = app.router.context.type || app.router.context.entry;
    if (model) {
      this.reveal(model);
      this.select(model);
    }
  }

  /** @param {Doc} doc */
  openDoc(doc) {
    if (app.disabledDocs.contains(doc) && doc.version) {
      this.listFold.open(
        this.find(`[data-slug='${doc.slug_without_version}']`),
      );
    }
    this.listFold.open(this.find(`[data-slug='${doc.slug}']`));
  }

  /** @param {Doc} doc */
  closeDoc(doc) {
    this.listFold.close(this.find(`[data-slug='${doc.slug}']`));
  }

  /** @param {Type} type */
  openType(type) {
    this.listFold.open(
      this.lists[type.doc.slug].find(`[data-slug='${type.slug}']`),
    );
  }

  /**
   * Renders as far as the entry, so that it can be revealed.
   *
   * @param {any} model
   */
  paginateTo(model) {
    if (this.lists[model.doc.slug] != null) {
      this.lists[model.doc.slug].paginateTo(model);
    }
  }

  /** @param {any} model The entry to bring into view. */
  scrollTo(model) {
    $.scrollTo(this.find(`a[href='${model.fullPath()}']`), null, "top", {
      margin: app.isMobile() ? 48 : 0,
    });
  }

  /** Folds the disabled docs in or out. */
  toggleDisabled() {
    if (this.disabledTitle.classList.contains("open-title")) {
      this.removeDisabledList();
      app.settings.set("hideDisabled", true);
    } else {
      this.appendDisabledList();
      app.settings.set("hideDisabled", false);
    }
  }

  /**
   * Enables the doc behind a row's Enable button.
   *
   * @param {ViewMouseEvent} event
   */
  onClick(event) {
    const target = $.eventTarget(event);
    if (
      this.disabledTitle &&
      $.hasChild(this.disabledTitle, target) &&
      target.tagName !== "A"
    ) {
      $.stopEvent(event);
      this.toggleDisabled();
      return;
    }
    const slug = target.getAttribute("data-enable");
    if (slug) {
      $.stopEvent(event);
      const doc = app.disabledDocs.findBy("slug", slug);
      if (doc) {
        this.onEnabled = this.onEnabled.bind(this);
        app.enableDoc(doc, this.onEnabled, this.onEnabled);
      }
    }
  }

  /** Rebuilds the list after a doc was enabled. */
  onEnabled() {
    this.reset();
    this.render();
  }

  /**
   * @param {string} route
   * @param {any} context
   */
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
