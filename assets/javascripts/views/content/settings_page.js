// @ts-check

/**
 * The preferences page: every setting, plus exporting and importing them.
 *
 * Some settings take effect immediately rather than on save, because the user
 * needs to see what they do.
 */
class SettingsPage extends app.View {
  static className = "_static";

  static events = {
    click: "onClick",
    change: "onChange",
  };

  /** Rebuilds the form from the stored preferences. */
  render() {
    this.html(this.tmpl("settingsPage", this.currentSettings()));
  }

  /** @returns {Record<string, unknown>} The values the form should show. */
  currentSettings() {
    const settings = {};
    settings.theme = app.settings.get("theme");
    settings.smoothScroll = !app.settings.get("fastScroll");
    settings.arrowScroll = app.settings.get("arrowScroll");
    settings.noAutofocus = app.settings.get("noAutofocus");
    settings.autoInstall = app.settings.get("autoInstall");
    settings.autoLatestVersion = app.settings.get("autoLatestVersion");
    settings.analyticsConsent = app.settings.get("analyticsConsent");
    settings.spaceScroll = app.settings.get("spaceScroll");
    settings.spaceTimeout = app.settings.get("spaceTimeout");
    settings.noDocSpecificIcon = app.settings.get("noDocSpecificIcon");
    settings.autoSupported = app.settings.autoSupported;
    for (var layout of app.Settings.LAYOUTS) {
      settings[layout] = app.settings.hasLayout(layout);
    }
    return settings;
  }

  /** @returns {string} */
  getTitle() {
    return "Preferences";
  }

  /** @param {string} value */
  setTheme(value) {
    app.settings.set("theme", value);
  }

  /**
   * @param {string} layout
   * @param {boolean} enable
   */
  toggleLayout(layout, enable) {
    app.settings.setLayout(layout, enable);
  }

  /** @param {boolean} enable */
  toggleSmoothScroll(enable) {
    app.settings.set("fastScroll", !enable);
  }

  /** @param {boolean} enable Clears the analytics cookies when turned off. */
  toggleAnalyticsConsent(enable) {
    app.settings.set("analyticsConsent", enable ? 1 : 0);
    if (!enable) {
      resetAnalytics();
    }
  }

  /** @param {boolean} enable */
  toggleSpaceScroll(enable) {
    app.settings.set("spaceScroll", enable ? 1 : 0);
  }

  /**
   * @param {string | number} value In seconds. Comes straight off the field,
   *   so it is a string; the store keeps it as one and the reader coerces.
   */
  setScrollTimeout(value) {
    return app.settings.set("spaceTimeout", value);
  }

  /**
   * @param {keyof SettingsValues} name
   * @param {boolean} enable
   */
  toggle(name, enable) {
    app.settings.set(name, enable);
  }

  /** Saves the preferences to a file. */
  export() {
    const data = new Blob([JSON.stringify(app.settings.export())], {
      type: "application/json",
    });
    $.download(data, "devdocs.json");
  }

  /**
   * Replaces the preferences with the contents of a file.
   *
   * @param {File} file
   * @param {HTMLInputElement} input The file field, reset once the import is done.
   */
  import(file, input) {
    if (!file || file.type !== "application/json") {
      new app.views.Notif("ImportInvalid", { autoHide: false });
      return;
    }

    const reader = new FileReader();
    reader.onloadend = function () {
      const data = (() => {
        try {
          return JSON.parse(/** @type {string} */ (reader.result));
        } catch (error) {}
      })();
      if (!data || data.constructor !== Object) {
        new app.views.Notif("ImportInvalid", { autoHide: false });
        return;
      }
      app.settings.import(data);
      $.trigger(input.form, "import");
    };
    reader.readAsText(file);
  }

  /** @param {ViewInputEvent} event */
  onChange(event) {
    const input = event.target;
    switch (input.name) {
      case "theme":
        this.setTheme(input.value);
        break;
      case "layout":
        this.toggleLayout(input.value, input.checked);
        break;
      case "smoothScroll":
        this.toggleSmoothScroll(input.checked);
        break;
      case "import":
        this.import(input.files[0], input);
        break;
      case "analyticsConsent":
        this.toggleAnalyticsConsent(input.checked);
        break;
      case "spaceScroll":
        this.toggleSpaceScroll(input.checked);
        break;
      case "spaceTimeout":
        this.setScrollTimeout(input.value);
        break;
      default:
        this.toggle(
          /** @type {keyof SettingsValues} */ (input.name),
          input.checked,
        );
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const target = $.eventTarget(event);
    switch (target.getAttribute("data-action")) {
      case "export":
        $.stopEvent(event);
        this.export();
        break;
    }
  }

  /** @param {unknown} context */
  onRoute(context) {
    this.render();
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.SettingsPage = SettingsPage;
