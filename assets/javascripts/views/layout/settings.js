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

  init() {
    this.addSubview((this.docPicker = new app.views.DocPicker()));
  }

  activate() {
    if (super.activate(...arguments)) {
      this.render();
      document.body.classList.remove(Settings.SIDEBAR_HIDDEN_LAYOUT);
    }
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.resetClass();
      this.docPicker.detach();
      if (app.settings.hasLayout(Settings.SIDEBAR_HIDDEN_LAYOUT)) {
        document.body.classList.add(Settings.SIDEBAR_HIDDEN_LAYOUT);
      }
    }
  }

  render() {
    this.docPicker.appendTo(this.sidebar);
    this.refreshElements();
    this.addClass("_in");
  }

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

  onChange() {
    this.addClass("_dirty");
  }

  onEnter() {
    this.save();
  }

  onSubmit(event) {
    event.preventDefault();
    this.save();
  }

  onImport() {
    this.addClass("_dirty");
    this.save({ import: true });
  }

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
