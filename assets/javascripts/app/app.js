// @ts-check

/**
 * The build-time configuration, rendered into the page by app/config.js.erb.
 *
 * @typedef {object} AppConfig
 * @property {string} db_filename
 * @property {string[]} default_docs Slugs enabled for a first-time visitor.
 * @property {Record<string, string>} docs_aliases Alternative spellings, by the name they resolve to.
 * @property {string} docs_origin Where the documentation files are served from.
 * @property {string} env
 * @property {number} history_cache_size
 * @property {string} index_filename
 * @property {number} max_results
 * @property {string} production_host
 * @property {string} search_param The query parameter a search is read from.
 * @property {string} sentry_dsn
 * @property {number} version Cache-busting stamp for the offline data.
 * @property {string} release
 * @property {string} mathml_stylesheet
 * @property {string} favicon_spritesheet
 * @property {string} service_worker_path
 * @property {boolean} service_worker_enabled
 */

/**
 * A doc as it appears in the manifest, before it becomes an `app.models.Doc`.
 *
 * @typedef {Record<string, any>} DocData
 */

/**
 * The application singleton, and the namespace everything else registers into.
 *
 * The registries below are keyed by name and populated by the files that
 * define their members, so they are typed as plain records rather than
 * enumerating 37 view classes.
 */
class App extends Events {
  // Kept so that isInjectionError can tell whether an extension replaced the
  // globals out from under us.
  _$ = $;
  _$$ = $$;
  _page = page;

  /** @type {Record<string, any>} */
  collections = {};
  /** @type {Record<string, any>} */
  models = {};
  /** @type {Record<string, any>} */
  templates = {};
  /** @type {Record<string, any>} */
  views = {};

  /** Set by app/config.js.erb. @type {AppConfig} */
  config;

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

  // The classes registered by the rest of app/, collections/, models/ and
  // views/. They're constructors rather than instances.
  /** @type {any} */ DB;
  /** @type {any} */ OfflineBackup;
  /** @type {any} */ Router;
  /** @type {any} */ Searcher;
  /** @type {any} */ SynchronousSearcher;
  /** @type {any} */ ServiceWorker;
  /** @type {any} */ Settings;
  /** @type {any} */ Shortcuts;
  /** @type {any} */ UpdateChecker;
  /** @type {any} */ Collection;
  /** @type {any} */ Model;
  /** @type {any} */ View;

  /**
   * The `window.onerror` handler that was installed before ours, if any.
   *
   * @type {any}
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
    if (app.ServiceWorker.isEnabled()) {
      this.serviceWorker = new app.ServiceWorker();
    }
    this.settings = new app.Settings();
    this.db = new app.DB();

    this.settings.initLayout();

    this.docs = new app.collections.Docs();
    this.disabledDocs = new app.collections.Docs();
    this.entries = new app.collections.Entries();

    this.router = new app.Router();
    this.shortcuts = new app.Shortcuts();
    this.document = new app.views.Document();
    if (this.isMobile()) {
      this.mobile = new app.views.Mobile();
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

  browserCheck() {
    if (this.isSupportedBrowser()) {
      return true;
    }
    document.body.innerHTML = app.templates.unsupportedBrowser;
    this.hideLoadingScreen();
    return false;
  }

  initErrorTracking() {
    // Show a warning message and don't track errors when the app is loaded
    // from a domain other than our own, because things are likely to break.
    // (e.g. cross-domain requests)
    if (this.isInvalidLocation()) {
      new app.views.Notif("InvalidLocation");
    } else {
      if (this.config.sentry_dsn) {
        Raven.config(this.config.sentry_dsn, {
          release: this.config.release,
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
              if (this.isInjectionError()) {
                this.onInjectionError();
                return false;
              }
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

  bootOne() {
    this.doc = new app.models.Doc(this.DOC);
    this.docs.reset([this.doc]);
    this.doc.load(this.start.bind(this), this.onBootError.bind(this), {
      readCache: true,
    });
    new app.views.Notice("singleDoc", this.doc);
    delete this.DOC;
  }

  async bootAll() {
    const docs = this.settings.getDocs();
    for (var doc of this.DOCS) {
      (docs.includes(doc.slug) ? this.docs : this.disabledDocs).add(doc);
    }
    delete this.DOCS;
    this.migrateDocs();
    await this.migrateToLatestVersions();
    this.docs.load(this.start.bind(this), this.onBootError.bind(this), {
      readCache: true,
      writeCache: true,
    });
  }

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

  initDoc(doc) {
    for (var type of doc.types.all()) {
      doc.entries.add(type.toEntry());
    }
    this.entries.add(doc.entries.all());
  }

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

  // With the "latest version" preference enabled, replace the enabled docs for
  // which a newer version is available with that version.
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

  // Saving drops the offline data of the docs that are disabled, so the index
  // of their latest version has to load before they are replaced. Loads no
  // more docs at once than Docs#load does.
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
        { length: Math.min(docs.length, app.collections.Docs.CONCURRENCY) },
        next,
      ),
    );

    return loaded;
  }

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

  saveDocs() {
    this.settings.setDocs(this.docs.all().map((doc) => doc.slug));
    this.db.migrate();
    return this.serviceWorker != null
      ? this.serviceWorker.updateInBackground()
      : undefined;
  }

  welcomeBack() {
    let visitCount = this.settings.get("count");
    this.settings.set("count", ++visitCount);
    if (visitCount === 5) {
      new app.views.Notif("Share", { autoHide: null });
    }
    new app.views.News();
    new app.views.Updates();
    return (this.updateChecker = new app.UpdateChecker());
  }

  reboot() {
    if (location.pathname !== "/" && location.pathname !== "/settings") {
      window.location = /** @type {any} */ (`/#${location.pathname}`);
    } else {
      window.location = /** @type {any} */ ("/");
    }
  }

  reload() {
    this.docs.clearCache();
    this.disabledDocs.clearCache();
    if (this.serviceWorker) {
      this.serviceWorker.reload();
    } else {
      this.reboot();
    }
  }

  reset() {
    this.localStorage.reset();
    this.settings.reset();
    if (this.db != null) {
      this.db.reset();
    }
    if (this.serviceWorker != null) {
      this.serviceWorker.update();
    }
    window.location = /** @type {any} */ ("/");
  }

  showTip(tip) {
    if (this.isSingleDoc()) {
      return;
    }
    const tips = this.settings.getTips();
    if (!tips.includes(tip)) {
      tips.push(tip);
      this.settings.setTips(tips);
      new app.views.Tip(tip);
    }
  }

  hideLoadingScreen() {
    if ($.overlayScrollbarsEnabled()) {
      document.body.classList.add("_overlay-scrollbars");
    }
    document.documentElement.classList.remove("_booting");
  }

  onBootError(...args) {
    this.trigger("bootError");
    this.hideLoadingScreen();
  }

  onQuotaExceeded() {
    if (this.quotaExceeded) {
      return;
    }
    this.quotaExceeded = true;
    new app.views.Notif("QuotaExceeded", { autoHide: null });
  }

  onCookieBlocked(key, value, actual) {
    if (this.cookieBlocked) {
      return;
    }
    this.cookieBlocked = true;
    new app.views.Notif("CookieBlocked", { autoHide: null });
    Raven.captureMessage(`CookieBlocked/${key}`, {
      level: "warning",
      extra: { value, actual },
    });
  }

  onWindowError(...args) {
    if (this.cookieBlocked) {
      return;
    }
    if (this.isInjectionError()) {
      this.onInjectionError();
    } else if (this.isAppError(args[0], args[1])) {
      if (typeof this.previousErrorHandler === "function") {
        this.previousErrorHandler(...args);
      }
      this.hideLoadingScreen();
      if (!this.errorNotif) {
        this.errorNotif = new app.views.Notif("Error");
      }
      this.errorNotif.show();
    }
  }

  onInjectionError() {
    if (!this.injectionError) {
      this.injectionError = true;
      alert(`\
JavaScript code has been injected in the page which prevents DevDocs from running correctly.
Please check your browser extensions/addons. `);
      Raven.captureMessage("injection error", { level: "info" });
    }
  }

  isInjectionError() {
    // Some browser extensions expect the entire web to use jQuery.
    // I gave up trying to fight back.
    return (
      window.$ !== app._$ ||
      window.$$ !== app._$$ ||
      window.page !== app._page ||
      typeof $.empty !== "function" ||
      typeof page.show !== "function"
    );
  }

  isAppError(error, file) {
    // Ignore errors from external scripts.
    return file && file.includes("devdocs") && file.endsWith(".js");
  }

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

  isSingleDoc() {
    return document.body.hasAttribute("data-doc");
  }

  isMobile() {
    return this._isMobile != null
      ? this._isMobile
      : (this._isMobile = app.views.Mobile.detect());
  }

  isAndroidWebview() {
    return this._isAndroidWebview != null
      ? this._isAndroidWebview
      : (this._isAndroidWebview = app.views.Mobile.detectAndroidWebview());
  }

  isInvalidLocation() {
    return (
      this.config.env === "production" &&
      !location.host.startsWith(app.config.production_host)
    );
  }
}

this.app = new App();
