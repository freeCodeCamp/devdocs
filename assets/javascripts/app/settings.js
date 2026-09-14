// @ts-check

import { app } from "./app.js";
import { config } from "./config.js";
import { CookiesStore } from "../lib/cookies_store.js";
import { $ } from "../lib/util.js";

/**
 * A setting the user turns on or off.
 *
 * It is a boolean going in, but CookiesStore writes `true` as `1` and parses
 * the digit back out on read, so it comes back as a number. A setting that was
 * never written falls back to its default, which is a real boolean. Both are
 * truthy or falsy as intended; only a strict comparison would go wrong.
 *
 * @typedef {boolean | number} StoredFlag
 */

/**
 * What each setting holds.
 *
 * @typedef {object} SettingsValues
 * @property {number} count How many times the user has visited.
 * @property {StoredFlag} hideDisabled
 * @property {StoredFlag} hideIntro
 * @property {number} news When the changelog was last read, as a Unix timestamp.
 * @property {StoredFlag} manualUpdate
 * @property {number} schema The offline database's schema version.
 * @property {StoredFlag} analyticsConsent Written as 1 or 0 rather than deleted,
 *   so that consent that was refused is remembered.
 * @property {string} theme `"auto"`, `"dark"` or `"default"`.
 * @property {number} spaceScroll How far space scrolls, as a fraction of the viewport.
 * @property {number | string} spaceTimeout How long after typing space stops
 *   scrolling, in seconds. Not an integer, so it comes back as a string.
 * @property {StoredFlag} noDocSpecificIcon
 * @property {StoredFlag} autoLatestVersion
 * @property {number} version The build the user last saw.
 * @property {StoredFlag} fastScroll
 * @property {StoredFlag} arrowScroll
 * @property {StoredFlag} noAutofocus
 * @property {StoredFlag} autoInstall
 * @property {number} dark Legacy; replaced by `theme`.
 * @property {string} docs The enabled slugs, separated by `/`.
 * @property {string} tips The tips already shown, separated by `/`.
 * @property {string} layout The layout classes, separated by spaces.
 * @property {number} size The sidebar's width, in pixels.
 */

/**
 * The user's preferences, stored in cookies so that the server can read them,
 * and mirrored in localStorage so that they outlive the cookies.
 *
 * `PREFERENCE_KEYS` are the ones the user controls and that a backup carries;
 * `INTERNAL_KEYS` are the app's own bookkeeping and stay out of backups.
 */
export class Settings {
  static PREFERENCE_KEYS = [
    "hideDisabled",
    "hideIntro",
    "manualUpdate",
    "fastScroll",
    "arrowScroll",
    "analyticsConsent",
    "docs",
    "dark", // legacy
    "theme",
    "layout",
    "size",
    "tips",
    "noAutofocus",
    "autoInstall",
    "autoLatestVersion",
    "spaceScroll",
    "spaceTimeout",
    "noDocSpecificIcon",
  ];

  static INTERNAL_KEYS = ["count", "schema", "version", "news"];

  static LAYOUTS = [
    "_max-width",
    "_sidebar-hidden",
    "_native-scrollbars",
    "_text-justify-hyphenate",
  ];

  /** @type {Record<string, string | number | boolean>} */
  static defaults = {
    count: 0,
    hideDisabled: false,
    hideIntro: false,
    news: 0,
    manualUpdate: false,
    schema: 1,
    analyticsConsent: false,
    theme: "auto",
    spaceScroll: 1,
    spaceTimeout: 0.5,
    noDocSpecificIcon: false,
    autoLatestVersion: false,
  };

  /** Opens the cookie store and starts following the system colour scheme. */
  constructor() {
    this.store = new CookiesStore();
    this.cache = {};
    this.autoSupported =
      window.matchMedia("(prefers-color-scheme)").media !== "not all";
    if (this.autoSupported) {
      this.darkModeQuery = window.matchMedia("(prefers-color-scheme: dark)");
      this.darkModeQuery.addListener(() => this.setTheme(this.get("theme")));
    }
  }

  /**
   * Reads a setting, falling back to its default. Cached after the first read.
   *
   * @template {keyof SettingsValues} K
   * @param {K} key
   * @returns {SettingsValues[K]}
   */
  get(key) {
    // The store and the defaults are both keyed by name but hold mixed types,
    // so the value is narrowed to the one this key stands for on the way out.
    const cache = /** @type {Record<string, unknown>} */ (this.cache);
    const cast = (/** @type {unknown} */ value) =>
      /** @type {SettingsValues[K]} */ (value);

    let left;
    if (cache.hasOwnProperty(key)) {
      return cast(cache[key]);
    }
    cache[key] =
      (left = this.store.get(key)) != null ? left : Settings.defaults[key];
    if (key === "theme" && cache[key] === "auto" && !this.darkModeQuery) {
      return cast((cache[key] = "default"));
    } else {
      return cast(cache[key]);
    }
  }

  /**
   * @template {keyof SettingsValues} K
   * @param {K} key
   * @param {SettingsValues[K]} value
   */
  set(key, value) {
    this.store.set(key, /** @type {string | number | boolean} */ (value));
    delete (/** @type {Record<string, unknown>} */ (this.cache))[key];
    if (key === "theme") {
      this.setTheme(/** @type {string} */ (value));
    }
  }

  /** @param {string} key */
  del(key) {
    this.store.del(key);
    delete (/** @type {Record<string, unknown>} */ (this.cache))[key];
  }

  /** @returns {boolean | undefined} Whether the user has ever chosen a set of docs. */
  hasDocs() {
    try {
      return !!this.store.get("docs");
    } catch (error) {}
  }

  /** @returns {string[]} The enabled doc slugs, or the defaults. */
  getDocs() {
    return (
      /** @type {string | undefined} */ (this.store.get("docs"))?.split("/") ||
      config.default_docs
    );
  }

  /** @param {string[]} docs */
  setDocs(docs) {
    this.set("docs", docs.join("/"));
  }

  /** @returns {string[]} The tips the user has already been shown. */
  getTips() {
    return /** @type {string | undefined} */ (this.store.get("tips"))?.split("/") || [];
  }

  /** @param {string[]} tips */
  setTips(tips) {
    this.set("tips", tips.join("/"));
  }

  /**
   * Applies a layout class and remembers it.
   *
   * @param {string} name One of `LAYOUTS`.
   * @param {boolean} enable
   */
  setLayout(name, enable) {
    this.toggleLayout(name, enable);

    const layout = /** @type {string} */ (
      this.store.get("layout") || ""
    ).split(" ");
    $.arrayDelete(layout, "");

    if (enable) {
      if (!layout.includes(name)) {
        layout.push(name);
      }
    } else {
      $.arrayDelete(layout, name);
    }

    if (layout.length > 0) {
      this.set("layout", layout.join(" "));
    } else {
      this.del("layout");
    }
  }

  /**
   * @param {string} name
   * @returns {boolean}
   */
  hasLayout(name) {
    const layout = /** @type {string} */ (
      this.store.get("layout") || ""
    ).split(" ");
    return layout.includes(name);
  }

  /** @param {number} value The sidebar width, in pixels. */
  setSize(value) {
    this.set("size", value);
  }

  /** @returns {Record<string, string>} Every stored setting, unparsed. */
  dump() {
    return this.store.dump();
  }

  /** @returns {Record<string, string>} The user's preferences, without the app's own bookkeeping. */
  export() {
    const data = this.dump();
    for (var key of Settings.INTERNAL_KEYS) {
      delete data[key];
    }
    return data;
  }

  /**
   * Replaces the user's preferences with `data`, dropping any it omits.
   *
   * @param {Record<string, unknown>} data
   */
  import(data) {
    let key, value;
    const object = this.export();
    for (key in object) {
      value = object[key];
      if (!data.hasOwnProperty(key)) {
        this.del(key);
      }
    }
    for (key in data) {
      value = data[key];
      if (Settings.PREFERENCE_KEYS.includes(key)) {
        this.set(key, value);
      }
    }
  }

  /** Clears every setting. */
  reset() {
    this.store.reset();
    this.cache = {};
  }

  /** Applies the stored theme and layout to the document. Runs before the first paint. */
  initLayout() {
    if (this.get("dark") === 1) {
      this.set("theme", "dark");
      this.del("dark");
    }
    this.setTheme(this.get("theme"));
    for (var layout of Settings.LAYOUTS) {
      this.toggleLayout(layout, this.hasLayout(layout));
    }
    this.initSidebarWidth();
  }

  /** @param {string} theme `"auto"`, `"dark"` or `"default"`. */
  setTheme(theme) {
    if (theme === "auto") {
      theme = this.darkModeQuery.matches ? "dark" : "default";
    }
    const { classList } = document.documentElement;
    classList.remove("_theme-default", "_theme-dark");
    classList.add("_theme-" + theme);
    this.updateColorMeta();
  }

  /** Points the `theme-color` meta at the header colour of the current theme. */
  updateColorMeta() {
    const color = getComputedStyle(document.documentElement)
      .getPropertyValue("--headerBackground")
      .trim();
    $("meta[name=theme-color]").setAttribute("content", color);
  }

  /**
   * @param {string} layout
   * @param {boolean} enable
   */
  toggleLayout(layout, enable) {
    const { classList } = document.body;
    // sidebar is always shown for settings; its state is updated in SettingsView
    if (layout !== "_sidebar-hidden" || !app.router?.isSettings) {
      classList.toggle(layout, enable);
    }
    classList.toggle("_overlay-scrollbars", $.overlayScrollbarsEnabled());
  }

  /** Applies the stored sidebar width. */
  initSidebarWidth() {
    const size = this.get("size");
    if (size) {
      document.documentElement.style.setProperty("--sidebarWidth", size + "px");
    }
  }
}
