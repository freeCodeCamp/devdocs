// @ts-check

/**
 * The preferences panel.
 *
 * Saving uninstalls the docs the user turned off and reloads the app, since
 * the offline database's schema is derived from the enabled docs.
 */
app.views.Settings = class Settings extends app.View {
  static SIDEBAR_HIDDEN_LAYOUT = "_sidebar-hidden";

  static el = "._settings";

  static elements = {
    sidebar: "._sidebar",
    saveBtn: 'button[type="submit"]',
    backBtn: "button[data-back]",
  };

  static events = {
    import: "onImport",
    change: "onChange",
    submit: "onSubmit",
    click: "onClick",
  };

  static shortcuts = { enter: "onEnter" };

  /** @inheritdoc */
  init() {
    this.addSubview((this.docPicker = new app.views.DocPicker()));
  }

  /** Also renders the panel and forces the sidebar to show. */
  activate() {
    if (super.activate()) {
      this.render();
      document.body.classList.remove(Settings.SIDEBAR_HIDDEN_LAYOUT);
    }
  }

  /** Also puts the sidebar back the way the user had it. */
  deactivate() {
    if (super.deactivate()) {
      this.resetClass();
      this.docPicker.detach();
      if (app.settings.hasLayout(Settings.SIDEBAR_HIDDEN_LAYOUT)) {
        document.body.classList.add(Settings.SIDEBAR_HIDDEN_LAYOUT);
      }
    }
  }

  /** Puts the doc picker in the sidebar and slides the panel in. */
  render() {
    this.docPicker.appendTo(this.sidebar);
    this.refreshElements();
    this.addClass("_in");
  }

  /**
   * Applies the chosen docs and reloads. Does nothing while a save is
   * already running.
   *
   * @param {{ import?: boolean }} [options] Pass `import` when the docs were
   *   just replaced by an import, so the picker isn't read back.
   */
  save(options) {
    if (options == null) {
      options = {};
    }
    if (!this.saving) {
      let docs;
      this.saving = true;

      if (options.import) {
        docs = app.settings.getDocs();
      } else {
        docs = this.docPicker.getSelectedDocs();
        app.settings.setDocs(docs);
      }

      this.saveBtn.textContent = "Saving\u2026";
      const disabledDocs = new app.collections.Docs(
        (() => {
          const result = [];
          for (var doc of app.docs.all()) {
            if (!docs.includes(doc.slug)) {
              result.push(doc);
            }
          }
          return result;
        })(),
      );
      disabledDocs.uninstall(() => {
        app.db.migrate();
        return app.reload();
      });
    }
  }

  /** Marks the panel as having unsaved changes. */
  onChange() {
    this.addClass("_dirty");
  }

  /** Saves on Enter. */
  onEnter() {
    this.save();
  }

  /** @param {ViewEvent} event */
  onSubmit(event) {
    event.preventDefault();
    this.save();
  }

  /** Saves after the preferences were replaced by an import. */
  onImport() {
    this.addClass("_dirty");
    this.save({ import: true });
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.which !== 1) {
      return;
    }
    if (event.target === this.backBtn) {
      $.stopEvent(event);
      app.router.show("/");
    }
  }
};
