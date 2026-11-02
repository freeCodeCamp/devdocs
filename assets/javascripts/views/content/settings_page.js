// @ts-check

import { app } from "../../app/app.js";
import { Settings } from "../../app/settings.js";
import { Docs } from "../../collections/docs.js";
import {
  FIND_PACKS_URL,
  GUIDE_URL,
  MANIFEST_FILENAME,
  findBuiltInDocs,
  packDocs,
  packUrl,
} from "../../lib/doc_packs.js";
import { resetAnalytics } from "../../lib/page.js";
import { $ } from "../../lib/util.js";
import { Notif } from "../misc/notif.js";
import { View } from "../view.js";
/** @import { SettingsValues } from "../../app/settings.js" */

/**
 * The preferences page: every setting, plus exporting and importing them.
 *
 * Some settings take effect immediately rather than on save, because the user
 * needs to see what they do.
 */
export class SettingsPage extends View {
  static className = "_static";

  static events = {
    click: "onClick",
    change: "onChange",
    input: "onInput",
    keydown: "onKeydown",
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
    settings.resume = !app.settings.get("noResume");
    settings.autoLatestVersion = app.settings.get("autoLatestVersion");
    settings.analyticsConsent = app.settings.get("analyticsConsent");
    settings.spaceScroll = app.settings.get("spaceScroll");
    settings.spaceTimeout = app.settings.get("spaceTimeout");
    settings.noDocSpecificIcon = app.settings.get("noDocSpecificIcon");
    settings.listPageSize = app.settings.get("listPageSize");
    settings.baseFont = app.settings.get("baseFont");
    settings.monoFont = app.settings.get("monoFont");
    settings.customCss = app.settings.get("customCss");
    settings.autoSupported = app.settings.autoSupported;
    settings.docPacks = app.docPacks.all().map((pack) => ({
      url: pack.url,
      name: pack.name,
      count: packDocs(pack).length,
    }));
    settings.docPackGuideUrl = GUIDE_URL;
    for (var layout of Settings.LAYOUTS) {
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
      new Notif("ImportInvalid", { autoHide: false });
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
        new Notif("ImportInvalid", { autoHide: false });
        return;
      }
      app.settings.import(data);
      $.trigger(input.form, "import");
    };
    reader.readAsText(file);
  }

  /**
   * Downloads the pack typed into the field and reloads, so that its docs show
   * in the list.
   */
  addPack() {
    const input = /** @type {HTMLInputElement} */ (this.find("._doc-pack-input"));
    const button = /** @type {HTMLButtonElement} */ (this.find('[data-action="addPack"]'));
    if (button.disabled) {
      return;
    }
    button.disabled = true;
    this.showPackHelp("");
    this.setPackStatus("Downloading the pack…");

    app.docPacks.add(input.value, (error, pack) => {
      if (error) {
        button.disabled = false;
        this.setPackStatus("");
        this.showPackHelp(
          this.tmpl("docPackHelp", {
            message: error.message,
            reason: error.reason,
            isGitHub: /^https:\/\/raw\.githubusercontent\.com\//.test(packUrl(input.value) || ""),
            builtIn: findBuiltInDocs(
              input.value,
              app.docs.all().concat(app.disabledDocs.all()).filter((doc) => !doc.pack),
            ),
            guideUrl: GUIDE_URL,
            findUrl: FIND_PACKS_URL,
          }),
        );
        return;
      }
      const count = packDocs(pack).length;
      this.setPackStatus(
        `Added “${pack.name}” with ${count} ${count === 1 ? "doc" : "docs"}. Reloading…`,
      );
      window.location.reload();
    });
  }

  /**
   * Removes a pack, with its docs and their offline copies, and reloads.
   *
   * @param {string} url
   */
  removePack(url) {
    const pack = app.docPacks.all().find((pack) => pack.url === url);
    if (
      !pack ||
      !window.confirm(`Remove “${pack.name}” and its docs from DevDocs?`)
    ) {
      return;
    }
    app.docPacks.remove(url);

    const slugs = new Set(packDocs(pack).map((doc) => doc.slug));
    app.settings.setDocs(app.settings.getDocs().filter((slug) => !slugs.has(slug)));
    new Docs(app.docs.all().filter((doc) => slugs.has(doc.slug))).uninstall(() =>
      window.location.reload(),
    );
  }

  /** @param {string} message */
  setPackStatus(message) {
    this.find("._doc-pack-status").textContent = message;
  }

  /** @param {string} html From the docPackHelp template, or empty to hide it. */
  showPackHelp(html) {
    this.find("._doc-pack-help").innerHTML = html;
  }

  /**
   * Shows which file an address will be read from, as it's typed, so that a
   * wrong address shows before it's tried.
   *
   * @param {ViewInputEvent} event
   */
  onInput(event) {
    if (event.target.name !== "packUrl") {
      return;
    }
    const url = packUrl(event.target.value);
    this.find("._doc-pack-preview").textContent = url
      ? `Reads ${url}${MANIFEST_FILENAME}`
      : "";
  }

  /** @param {ViewInputEvent} event */
  onChange(event) {
    const input = event.target;
    switch (input.name) {
      case "resume":
        app.settings.set("noResume", !input.checked);
        break;
      case "packUrl":
        // Not a preference: it's only read when the pack is added.
        event.stopPropagation();
        break;
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
      case "baseFont":
      case "monoFont":
        app.settings.setFont(input.name, input.value);
        break;
      case "customCss":
        app.settings.setCustomCss(input.value);
        break;
      case "listPageSize":
        app.settings.set("listPageSize", Math.max(0, parseInt(input.value) || 0));
        break;
      default:
        this.toggle(
          /** @type {keyof SettingsValues} */ (input.name),
          input.checked,
        );
    }
  }

  /**
   * Keeps the keyboard shortcuts out of the CSS field, where Enter and the
   * arrow keys edit the text, and out of the pack address field.
   *
   * @param {ViewKeyboardEvent} event
   */
  onKeydown(event) {
    if (event.target.tagName === "TEXTAREA") {
      event.stopPropagation();
    } else if (/** @type {HTMLInputElement} */ (event.target).name === "packUrl") {
      // Enter adds the pack rather than saving the preferences.
      event.stopPropagation();
      if (event.key === "Enter") {
        event.preventDefault();
        this.addPack();
      }
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
      case "addPack":
        $.stopEvent(event);
        this.addPack();
        break;
      case "removePack":
        $.stopEvent(event);
        this.removePack(target.getAttribute("data-url"));
        break;
    }
  }

  /** @param {unknown} context */
  onRoute(context) {
    this.render();
  }
}
