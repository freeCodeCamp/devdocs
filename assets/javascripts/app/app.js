// @ts-check

import { config } from "./config.js";
import { DB } from "./db.js";
import { Router } from "./router.js";
import { AppServiceWorker } from "./serviceworker.js";
import { Settings } from "./settings.js";
import { Shortcuts } from "./shortcuts.js";
import { UpdateChecker } from "./update_checker.js";
import { Docs } from "../collections/docs.js";
import { Entries } from "../collections/entries.js";
import { CookiesStore } from "../lib/cookies_store.js";
import { Events } from "../lib/events.js";
import { LocalStorageStore } from "../lib/local_storage_store.js";
import { $ } from "../lib/util.js";
import { Doc } from "../models/doc.js";
import { unsupportedBrowser } from "../templates/error_tmpl.js";
import { AppDocument } from "../views/layout/document.js";
import { Mobile } from "../views/layout/mobile.js";
import { News } from "../views/misc/news.js";
import { Notice } from "../views/misc/notice.js";
import { Notif } from "../views/misc/notif.js";
import { Tip } from "../views/misc/tip.js";
import { Updates } from "../views/misc/updates.js";

/**
 * A doc as it appears in the manifest, before it becomes a `Doc`.
 *
 * @typedef {Record<string, unknown>} DocData
 */

/**
 * The application singleton: the live state the rest of the app reads off, and
 * the boot sequence that builds it. Classes are imported where they are used
 * rather than registered here.
 */
export class App extends Events {
  /**
   * The manifest of every available doc, set by docs.js.erb. Deleted once the
   * docs have been read into the collections.
   *
   * @type {DocData[] | undefined}
   */
  DOCS;

  /**
   * In single-doc mode, the one doc being shown, read off the body. Deleted
   * once it has been read.
   *
   * @type {DocData | undefined}
   */
  DOC;

  /**
   * The news entries, newest first, set by templates/pages/news_tmpl.js.erb.
   * Each is a date followed by one entry per line.
   *
   * @type {Array<[string, ...string[]]>}
   */
  news;

  /**
   * The `window.onerror` handler that was installed before ours, if any.
   *
   * @type {unknown}
   */
  previousErrorHandler;

  /**
   * The stores and mode of the most recent IndexedDB transaction, tracked by
   * app/db.js so that a hung transaction can be reported.
   *
   * @type {[string | string[], IDBTransactionMode] | undefined}
   */
  lastIDBTransaction;

  /** Wires up the app and boots it. Called once the document is ready. */
  init() {
    try {
      this.initErrorTracking();
    } catch (error) {}
    if (!this.browserCheck()) {
      return;
    }

    this.el = $("._app");
    this.localStorage = new LocalStorageStore();
    if (AppServiceWorker.isEnabled()) {
      this.serviceWorker = new AppServiceWorker();
    }
    this.settings = new Settings();
    this.db = new DB();

    this.settings.initLayout();

    this.docs = new Docs();
    this.disabledDocs = new Docs();
    this.entries = new Entries();

    this.router = new Router();
    this.shortcuts = new Shortcuts();
    this.document = new AppDocument();
    if (this.isMobile()) {
      this.mobile = new Mobile();
    }

    if (document.body.hasAttribute("data-doc")) {
      this.DOC = JSON.parse(document.body.getAttribute("data-doc"));
      this.bootOne();
    } else if (this.DOCS) {
      this.bootAll();
    } else {
      this.onBootError();
    }
  }

  /**
   * @returns {boolean} Whether to carry on booting. Replaces the page with a
   *   warning when the browser is too old.
   */
  browserCheck() {
    if (this.isSupportedBrowser()) {
      return true;
    }
    document.body.innerHTML = /** @type {string} */ (
      unsupportedBrowser
    );
    this.hideLoadingScreen();
    return false;
  }

  /** Wires up Sentry and the global error handlers. */
  initErrorTracking() {
    // Show a warning message and don't track errors when the app is loaded
    // from a domain other than our own, because things are likely to break.
    // (e.g. cross-domain requests)
    if (this.isInvalidLocation()) {
      new Notif("InvalidLocation");
    } else {
      if (config.sentry_dsn) {
        Raven.config(config.sentry_dsn, {
          release: config.release,
          whitelistUrls: [/devdocs/],
          includePaths: [/devdocs/],
          ignoreErrors: [/NPObject/, /NS_ERROR/, /^null$/, /EvalError/],
          tags: {
            mode: this.isSingleDoc() ? "single" : "full",
            iframe: (window.top !== window).toString(),
            electron: (!!window.process?.versions?.electron).toString(),
          },
          shouldSendCallback: () => {
            try {
              if (this.isAndroidWebview()) {
                return false;
              }
            } catch (error) {}
            return true;
          },
          dataCallback(data) {
            try {
              data.user ||= {};
              Object.assign(data.user, app.settings.dump());
              if (data.user.docs) {
                data.user.docs = data.user.docs.split("/");
              }
              if (app.lastIDBTransaction) {
                data.user.lastIDBTransaction = app.lastIDBTransaction;
              }
              data.tags.scriptCount = document.scripts.length;
            } catch (error) {}
            return data;
          },
        }).install();
      }
      this.previousErrorHandler = onerror;
      window.onerror = this.onWindowError.bind(this);
      CookiesStore.onBlocked = this.onCookieBlocked;
    }
  }

  /** Boots in single-doc mode, with only the doc named on the body. */
  bootOne() {
    this.doc = new Doc(this.DOC);
    this.docs.reset([this.doc]);
    this.doc.load(this.start.bind(this), this.onBootError.bind(this), {
      readCache: true,
    });
    new Notice("singleDoc", this.doc);
    delete this.DOC;
  }

  /** Boots with every doc in the manifest, enabled or not. */
  async bootAll() {
    const docs = this.settings.getDocs();
    for (var doc of this.DOCS) {
      (docs.includes(/** @type {string} */ (doc.slug)) ? this.docs : this.disabledDocs).add(doc);
    }
    delete this.DOCS;
    this.migrateDocs();
    await this.migrateToLatestVersions();
    this.docs.load(this.start.bind(this), this.onBootError.bind(this), {
      readCache: true,
      writeCache: true,
    });
  }

  /** Builds the search index from the loaded docs and starts routing. */
  start() {
    let doc;
    for (doc of this.docs.all()) {
      this.entries.add(doc.toEntry());
    }
    for (doc of this.disabledDocs.all()) {
      this.entries.add(doc.toEntry());
    }
    for (doc of this.docs.all()) {
      this.initDoc(doc);
    }
    this.trigger("ready");
    this.router.start();
    this.hideLoadingScreen();
    setTimeout(() => {
      if (!this.doc) {
        this.welcomeBack();
      }
      return this.removeEvent("ready bootError");
    }, 50);
  }

  /**
   * Adds a doc's types and entries to the search index.
   *
   * @param {Doc} doc
   */
  initDoc(doc) {
    for (var type of doc.types.all()) {
      doc.entries.add(type.toEntry());
    }
    this.entries.add(doc.entries.all());
  }

  /** Re-points enabled slugs that have since been renamed or reorganized. */
  migrateDocs() {
    let needsSaving;
    for (var slug of this.settings.getDocs()) {
      if (!this.docs.findBy("slug", slug)) {
        var doc;

        needsSaving = true;
        if (slug === "webpack~2") {
          doc = this.disabledDocs.findBy("slug", "webpack");
        }
        if (slug === "angular~4_typescript") {
          doc = this.disabledDocs.findBy("slug", "angular");
        }
        if (slug === "angular~2_typescript") {
          doc = this.disabledDocs.findBy("slug", "angular~2");
        }
        if (!doc) {
          doc = this.disabledDocs.findBy("slug_without_version", slug);
        }
        if (doc) {
          this.disabledDocs.remove(doc);
          this.docs.add(doc);
        }
      }
    }

    if (needsSaving) {
      this.saveDocs();
    }
  }

  /**
   * With the "latest version" preference enabled, replace the enabled docs for
   * which a newer version is available with that version.
   */
  async migrateToLatestVersions() {
    if (!this.settings.get("autoLatestVersion")) {
      return;
    }

    const allDocs = this.docs.all().concat(this.disabledDocs.all());
    // The same version can supersede several enabled docs, so it's only loaded
    // once, e.g. when both CMake 3.9 and CMake 3.10 are enabled.
    const migrations = new Map();

    for (const outdated of this.docs.all()) {
      const latest = outdated.findLatestVersion(allDocs);
      if (latest === outdated) {
        continue;
      }
      if (!migrations.has(latest)) {
        migrations.set(latest, []);
      }
      migrations.get(latest).push(outdated);
    }

    const loaded = await this.loadLatestVersions([...migrations.keys()]);
    let needsSaving;

    for (const [latest, outdatedDocs] of migrations) {
      if (!loaded.has(latest)) {
        continue;
      }
      for (const outdated of outdatedDocs) {
        this.docs.remove(outdated);
        this.disabledDocs.add(outdated);
      }
      if (!this.docs.contains(latest)) {
        this.disabledDocs.remove(latest);
        this.docs.add(latest);
      }
      needsSaving = true;
    }

    if (needsSaving) {
      this.docs.sort();
      this.saveDocs();
    }
  }

  /**
   * Saving drops the offline data of the docs that are disabled, so the index
   * of their latest version has to load before they are replaced. Loads no
   * more docs at once than Docs#load does.
   *
   * @param {Doc[]} docs
   * @returns {Promise<Set<unknown>>} The docs whose index loaded.
   */
  async loadLatestVersions(docs) {
    const loaded = new Set();
    let i = 0;

    const next = async () => {
      while (i < docs.length) {
        const doc = docs[i++];
        const success = await new Promise((resolve) =>
          doc.load(
            () => resolve(true),
            () => resolve(false),
            { readCache: true, writeCache: true },
          ),
        );
        if (success) {
          loaded.add(doc);
        }
      }
    };

    await Promise.all(
      Array.from(
        { length: Math.min(docs.length, Docs.CONCURRENCY) },
        next,
      ),
    );

    return loaded;
  }

  /**
   * Turns a doc on, loading its index and installing it when the user has
   * asked for that.
   *
   * @param {Doc} doc
   * @param {() => void} _onSuccess
   * @param {() => void} onError
   */
  enableDoc(doc, _onSuccess, onError) {
    if (this.docs.contains(doc)) {
      return;
    }

    const onSuccess = () => {
      if (this.docs.contains(doc)) {
        return;
      }
      this.disabledDocs.remove(doc);
      this.docs.add(doc);
      this.docs.sort();
      this.initDoc(doc);
      this.saveDocs();
      if (app.settings.get("autoInstall")) {
        doc.install(_onSuccess, onError);
      } else {
        _onSuccess();
      }
    };

    doc.load(onSuccess, onError, { writeCache: true });
  }

  /** Stores the enabled docs and brings the offline database in line. */
  saveDocs() {
    this.settings.setDocs(this.docs.all().map((doc) => doc.slug));
    this.db.migrate();
    return this.serviceWorker != null
      ? this.serviceWorker.updateInBackground()
      : undefined;
  }

  /** Shows what's new since the user's last visit, and starts the update checks. */
  welcomeBack() {
    let visitCount = this.settings.get("count");
    this.settings.set("count", ++visitCount);
    if (visitCount === 5) {
      new Notif("Share", { autoHide: null });
    }
    new News();
    new Updates();
    return (this.updateChecker = new UpdateChecker());
  }

  /** Reloads the app, keeping the current path. */
  reboot() {
    if (location.pathname !== "/" && location.pathname !== "/settings") {
      window.location.href = `/#${location.pathname}`;
    } else {
      window.location.href = "/";
    }
  }

  /** Drops the cached indexes and reloads the app. */
  reload() {
    this.docs.clearCache();
    this.disabledDocs.clearCache();
    if (this.serviceWorker) {
      this.serviceWorker.reload();
    } else {
      this.reboot();
    }
  }

  /** Clears every trace of the app and returns to the index. */
  reset() {
    this.localStorage.reset();
    this.settings.reset();
    if (this.db != null) {
      this.db.reset();
    }
    if (this.serviceWorker != null) {
      this.serviceWorker.update();
    }
    window.location.href = "/";
  }

  /**
   * Shows a tip, unless the user has already seen it.
   *
   * @param {string} tip
   */
  showTip(tip) {
    if (this.isSingleDoc()) {
      return;
    }
    const tips = this.settings.getTips();
    if (!tips.includes(tip)) {
      tips.push(tip);
      this.settings.setTips(tips);
      new Tip(tip);
    }
  }

  /** Takes the boot screen down. */
  hideLoadingScreen() {
    if ($.overlayScrollbarsEnabled()) {
      document.body.classList.add("_overlay-scrollbars");
    }
    document.documentElement.classList.remove("_booting");
  }

  /** @param {...unknown} args */
  onBootError(...args) {
    this.trigger("bootError");
    this.hideLoadingScreen();
  }

  /** Warns the user that the offline database has outgrown its quota. Once. */
  onQuotaExceeded() {
    if (this.quotaExceeded) {
      return;
    }
    this.quotaExceeded = true;
    new Notif("QuotaExceeded", { autoHide: null });
  }

  /**
   * Warns the user that cookies are blocked, so preferences won't stick. Once.
   *
   * @param {string} key
   * @param {unknown} value What was written.
   * @param {unknown} actual What was read back.
   */
  onCookieBlocked(key, value, actual) {
    if (this.cookieBlocked) {
      return;
    }
    this.cookieBlocked = true;
    new Notif("CookieBlocked", { autoHide: null });
    Raven.captureMessage(`CookieBlocked/${key}`, {
      level: "warning",
      extra: { value, actual },
    });
  }

  /** @param {...unknown} args The `window.onerror` arguments. */
  onWindowError(...args) {
    if (this.cookieBlocked) {
      return;
    }
    if (this.isAppError(args[0], /** @type {string} */ (args[1]))) {
      if (typeof this.previousErrorHandler === "function") {
        this.previousErrorHandler(...args);
      }
      this.hideLoadingScreen();
      if (!this.errorNotif) {
        this.errorNotif = new Notif("Error");
      }
      this.errorNotif.show();
    }
  }

  /**
   * @param {unknown} error
   * @param {string} [file] Where the error came from.
   * @returns {boolean} Whether the error came from the app rather than an
   *   external script.
   */
  isAppError(error, file) {
    // Ignore errors from external scripts.
    return file && file.includes("devdocs") && file.endsWith(".js");
  }

  /** @returns {boolean} Whether the browser has everything the app needs. */
  isSupportedBrowser() {
    try {
      const features = {
        bind: !!Function.prototype.bind,
        pushState: !!history.pushState,
        matchMedia: !!window.matchMedia,
        insertAdjacentHTML: !!document.body.insertAdjacentHTML,
        defaultPrevented:
          document.createEvent("CustomEvent").defaultPrevented === false,
        cssVariables: !!CSS.supports?.("(--t: 0)"),
      };

      for (var key in features) {
        var value = features[key];
        if (!value) {
          Raven.captureMessage(`unsupported/${key}`, { level: "info" });
          return false;
        }
      }

      return true;
    } catch (error) {
      Raven.captureMessage("unsupported/exception", {
        level: "info",
        extra: { error },
      });
      return false;
    }
  }

  /** @returns {boolean} Whether the app is showing one doc rather than all of them. */
  isSingleDoc() {
    return document.body.hasAttribute("data-doc");
  }

  /** @returns {boolean} Whether to use the phone layout. Decided once. */
  isMobile() {
    return this._isMobile != null
      ? this._isMobile
      : (this._isMobile = Mobile.detect());
  }

  /** @returns {boolean} Whether the app is inside an Android webview. Decided once. */
  isAndroidWebview() {
    return this._isAndroidWebview != null
      ? this._isAndroidWebview
      : (this._isAndroidWebview = Mobile.detectAndroidWebview());
  }

  /** @returns {boolean} Whether the app is being served from someone else's domain. */
  isInvalidLocation() {
    return (
      config.env === "production" &&
      !location.host.startsWith(config.production_host)
    );
  }
}

export const app = new App();
