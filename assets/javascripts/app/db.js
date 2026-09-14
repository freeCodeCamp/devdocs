// @ts-check

import { app } from "./app.js";
import { ajax } from "../lib/ajax.js";
import { SettingsStore } from "../lib/settings_store.js";
import { $ } from "../lib/util.js";
/** @import { Doc } from "../models/doc.js" */
/** @import { Entry } from "../models/entry.js" */

/**
 * `DB#useIndexedDB` is a method that the instance shadows with the boolean it
 * returned, so the write needs a view of the instance that expects the value.
 *
 * @param {DB} db
 * @returns {{ useIndexedDB: boolean }}
 */
const useIndexedDBOf = (db) =>
  /** @type {{ useIndexedDB: boolean }} */ (/** @type {unknown} */ (db));

/**
 * An IndexedDB event, whose target is the request or transaction that raised
 * it. lib.dom types `Event#target` as a bare `EventTarget`.
 *
 * @typedef {Event & { target: IDBRequest }} IDBEvent
 */

/**
 * How a transaction is opened.
 *
 * @typedef {object} DBTransactionOptions
 * @property {string | string[]} stores
 * @property {IDBTransactionMode} mode
 * @property {boolean} [ignoreError] Set to `false` to let errors surface.
 * @property {boolean} [ignoreAbort] Set to `false` to let aborts surface.
 */

/**
 * The offline store: the docs' pages, kept in IndexedDB.
 *
 * The database is opened for the length of one batch of work and closed again,
 * so every operation goes through `db`, which queues its callback and hands it
 * the open database. When IndexedDB can't be used at all — private mode, a
 * buggy implementation, an exceeded quota — `useIndexedDB` is turned off and
 * every callback is run with no database, which makes the callers fall back to
 * the network.
 *
 * The version number packs the schema version and the user's own version
 * together, so that a doc being installed can force an upgrade without
 * colliding with a schema change.
 */
export class DB {
  static NAME = "docs";
  static VERSION = 15;

  /**
   * The docs' entry indexes, by slug, as `[mtime, index]`. Not one store per
   * doc: a doc's index is cached before it is enabled (see App#enableDoc), so
   * a store of its own wouldn't exist yet. And not inside the doc's own store
   * either, where `index` is the doc's home page and DB#store clears
   * everything it holds on install.
   */
  static INDEXES_STORE = "indexes";

  /** The localStorage keys that aren't an index an older app left behind. */
  static NOT_INDEXES = [SettingsStore.KEY, "override-mobile-detect"];

  /** Probes for IndexedDB support and prepares the callback queue. */
  constructor() {
    this.versionMultipler = $.isIE() ? 1e5 : 1e9;
    // Shadows the method of the same name with the answer it gives.
    useIndexedDBOf(this).useIndexedDB = this.useIndexedDB();
    this.callbacks = [];
  }

  /**
   * Opens the database and runs `fn` with it, or with nothing when IndexedDB
   * is unavailable. Callbacks queued while an open is in flight share it.
   *
   * @param {(db?: IDBDatabase) => void} [fn]
   */
  db(fn) {
    if (!this.useIndexedDB) {
      return fn();
    }
    if (fn) {
      this.callbacks.push(fn);
    }
    if (this.open) {
      return;
    }

    try {
      this.open = true;
      const req = indexedDB.open(
        DB.NAME,
        DB.VERSION * this.versionMultipler + this.userVersion(),
      );
      req.onsuccess = (event) =>
      this.onOpenSuccess(/** @type {IDBEvent} */ (event));
      req.onerror = (event) =>
      this.onOpenError(/** @type {IDBEvent} */ (event));
      req.onupgradeneeded = (event) => this.onUpgradeNeeded(event);
    } catch (error) {
      this.fail("exception", error);
    }
  }

  /**
   * Runs the queued callbacks, unless the database turns out to be empty or
   * buggy.
   *
   * @param {IDBEvent} event
   */
  onOpenSuccess(event) {
    let error;
    const db = /** @type {IDBEvent} */ (/** @type {unknown} */ (event)).target
      .result;

    if (db.objectStoreNames.length === 0) {
      try {
        db.close();
      } catch (error1) {}
      this.open = false;
      this.fail("empty");
    } else if ((error = this.buggyIDB(db))) {
      try {
        db.close();
      } catch (error2) {}
      this.open = false;
      this.fail("buggy", error);
    } else {
      this.runCallbacks(db);
      this.open = false;
      db.close();
    }
  }

  /** @param {IDBEvent} event */
  onOpenError(event) {
    event.preventDefault();
    this.open = false;
    const { error } = /** @type {IDBEvent} */ (event).target;

    switch (error.name) {
      case "QuotaExceededError":
        this.onQuotaExceededError();
        break;
      case "VersionError":
        this.onVersionError();
        break;
      case "InvalidStateError":
        this.fail("private_mode");
        break;
      default:
        this.fail("cant_open", error);
    }
  }

  /**
   * Turns IndexedDB off for the rest of the session and drains the queue.
   *
   * @param {string} reason
   * @param {unknown} [error]
   */
  fail(reason, error) {
    this.cachedDocs = null;
    useIndexedDBOf(this).useIndexedDB = false;
    if (!this.reason) {
      this.reason = reason;
    }
    if (!this.error) {
      this.error = error;
    }
    if (error) {
      if (typeof console.error === "function") {
        console.error("IDB error", error);
      }
    }
    this.runCallbacks();
    if (error && reason === "cant_open") {
      const { name, message } = /** @type {{ name?: string, message?: string }} */ (
        error
      );
      Raven.captureMessage(`${name}: ${message}`, {
        level: "warning",
        fingerprint: [name],
      });
    }
  }

  /** Drops the database and tells the app, so it can warn the user. */
  onQuotaExceededError() {
    this.reset();
    this.db();
    app.onQuotaExceeded();
    Raven.captureMessage("QuotaExceededError", { level: "warning" });
  }

  /** Reopens at the stored version, to tell a schema bump from a user one. */
  onVersionError() {
    const req = indexedDB.open(DB.NAME);
    req.onsuccess = (event) => {
      return this.handleVersionMismatch(
        /** @type {IDBRequest<IDBDatabase>} */ (event.target).result.version,
      );
    };
    req.onerror = (event) => {
      event.preventDefault();
      return this.fail("cant_open", req.error);
    };
  }

  /**
   * @param {number} actualVersion The version the stored database is at.
   */
  handleVersionMismatch(actualVersion) {
    if (Math.floor(actualVersion / this.versionMultipler) !== DB.VERSION) {
      this.fail("version");
    } else {
      this.setUserVersion(actualVersion - DB.VERSION * this.versionMultipler);
      this.db();
    }
  }

  /**
   * @param {IDBDatabase} db
   * @returns {unknown} The error a known-broken implementation throws, if any.
   */
  buggyIDB(db) {
    if (this.checkedBuggyIDB) {
      return;
    }
    this.checkedBuggyIDB = true;
    try {
      this.idbTransaction(db, {
        stores: $.makeArray(db.objectStoreNames).slice(0, 2),
        mode: "readwrite",
      }).abort(); // https://bugs.webkit.org/show_bug.cgi?id=136937
      return;
    } catch (error) {
      return error;
    }
  }

  /**
   * @param {IDBDatabase} [db] Omitted when the database couldn't be opened.
   */
  runCallbacks(db) {
    let fn;
    while ((fn = this.callbacks.shift())) {
      fn(db);
    }
  }

  /**
   * Creates an object store per enabled doc, plus the two the app keeps for
   * itself: the installed docs' mtimes, and the cached entry indexes.
   *
   * @param {IDBVersionChangeEvent} event
   */
  onUpgradeNeeded(event) {
    const db = /** @type {IDBEvent} */ (/** @type {unknown} */ (event)).target
      .result;
    if (!db) {
      return;
    }

    const objectStoreNames = $.makeArray(db.objectStoreNames);

    for (var store of ["docs", DB.INDEXES_STORE]) {
      if (!$.arrayDelete(objectStoreNames, store)) {
        try {
          db.createObjectStore(store);
        } catch (error) {}
      }
    }

    for (var doc of app.docs.all()) {
      if (!$.arrayDelete(objectStoreNames, doc.slug)) {
        try {
          db.createObjectStore(doc.slug);
        } catch (error1) {}
      }
    }

    for (var name of objectStoreNames) {
      try {
        db.deleteObjectStore(name);
      } catch (error2) {}
    }
  }

  /**
   * Replaces the doc's stored pages. Whatever was there before is cleared.
   *
   * @param {Doc} doc
   * @param {Record<string, string>} data The doc's pages, by path.
   * @param {number} mtime
   * @param {() => void} onSuccess
   * @param {(error?: unknown) => void} onError
   * @param {boolean} [_retry] Internal: whether a failure may bump the schema and try again.
   */
  store(doc, data, mtime, onSuccess, onError, _retry) {
    if (_retry == null) {
      _retry = true;
    }
    this.db((db) => {
      if (!db) {
        onError();
        return;
      }

      const retry = () => {
        this.migrate();
        setTimeout(() => {
          return this.store(doc, data, mtime, onSuccess, onError, false);
        }, 0);
      };

      let txn;
      try {
        txn = this.idbTransaction(db, {
          stores: ["docs", doc.slug],
          mode: "readwrite",
          ignoreError: false,
        });
      } catch (error) {
        // The object store doesn't exist yet, which happens when the doc was
        // enabled while the database was being opened. Bumping the schema
        // creates it (see onUpgradeNeeded).
        if (error.name === "NotFoundError" && _retry) {
          retry();
        } else {
          onError(error);
        }
        return;
      }

      txn.oncomplete = () => {
        if (this.cachedDocs != null) {
          this.cachedDocs[doc.slug] = mtime;
        }
        onSuccess();
      };
      txn.onerror = (event) => {
        event.preventDefault();
        if (txn.error?.name === "NotFoundError" && _retry) {
          retry();
        } else {
          onError(event);
        }
      };

      let store = txn.objectStore(doc.slug);
      store.clear();
      for (var path in data) {
        var content = data[path];
        store.add(content, path);
      }

      store = txn.objectStore("docs");
      store.put(mtime, doc.slug);
    });
  }

  /**
   * Removes the doc's pages.
   *
   * @param {Doc} doc
   * @param {() => void} onSuccess
   * @param {(error?: unknown) => void} onError
   * @param {boolean} [_retry] Internal: whether a failure may bump the schema and try again.
   */
  unstore(doc, onSuccess, onError, _retry) {
    if (_retry == null) {
      _retry = true;
    }
    this.db((db) => {
      if (!db) {
        onError();
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: ["docs", doc.slug],
        mode: "readwrite",
        ignoreError: false,
      });
      txn.oncomplete = () => {
        if (this.cachedDocs != null) {
          delete this.cachedDocs[doc.slug];
        }
        onSuccess();
      };
      txn.onerror = (event) => {
        event.preventDefault();
        if (txn.error?.name === "NotFoundError" && _retry) {
          this.migrate();
          setTimeout(() => {
            return this.unstore(doc, onSuccess, onError, false);
          }, 0);
        } else {
          onError(event);
        }
      };

      let store = txn.objectStore("docs");
      store.delete(doc.slug);

      store = txn.objectStore(doc.slug);
      store.clear();
    });
  }

  // Reads back everything that store() wrote for a doc: its pages and the
  // mtime it was installed with. Calls back with null when the doc isn't
  // installed or can't be read.
  /**
   * Reads the doc's stored pages, for a backup.
   *
   * @param {Doc} doc
   * @param {(result: { mtime: number, data: unknown } | null) => void} callback
   */
  dump(doc, callback) {
    this.db((db) => {
      if (!db || !db.objectStoreNames.contains(doc.slug)) {
        callback(null);
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: ["docs", doc.slug],
        mode: "readonly",
        ignoreError: false,
        ignoreAbort: false,
      });
      const data = {};
      let failed = false;
      let mtime = null;

      txn.oncomplete = () => callback(failed || !mtime ? null : { mtime, data });
      txn.onerror = function (event) {
        event.preventDefault();
        failed = true;
      };
      txn.onabort = function (event) {
        event.preventDefault();
        callback(null);
      };

      txn.objectStore("docs").get(doc.slug).onsuccess = (event) => {
        mtime = /** @type {IDBEvent} */ (event).target.result;
      };

      const req = txn.objectStore(doc.slug).openCursor();
      req.onsuccess = (event) => {
        const cursor = /** @type {IDBEvent} */ (event).target.result;
        if (!cursor) {
          return;
        }
        data[cursor.key] = cursor.value;
        cursor.continue();
      };
    });
  }

  /**
   * @param {Doc} doc
   * @param {(version: number | false) => void} fn The stored `mtime`, or `false` when it isn't installed.
   */
  version(doc, fn) {
    const version = this.cachedVersion(doc);
    if (version != null) {
      fn(version);
      return;
    }

    this.db((db) => {
      if (!db) {
        fn(false);
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: ["docs"],
        mode: "readonly",
      });
      const store = txn.objectStore("docs");

      const req = store.get(doc.slug);
      req.onsuccess = function () {
        fn(req.result);
      };
      req.onerror = function (event) {
        event.preventDefault();
        fn(false);
      };
    });
  }

  /**
   * Reads a doc's cached entry index.
   *
   * @param {Doc} doc
   * @param {number} mtime The build to read it for; one cached for an earlier
   *   build is dropped rather than returned.
   * @param {(index?: unknown) => void} fn Called with the index, or with
   *   nothing when there isn't a usable one.
   */
  loadIndex(doc, mtime, fn) {
    this.db((db) => {
      let req;
      try {
        req = this.indexesStore(db, "readonly").get(doc.slug);
      } catch (error) {
        this.onMissingIndexesStore(error);
        fn();
        return;
      }

      req.onsuccess = () => {
        const cached = req.result;
        if (!cached) {
          fn();
        } else if (cached[0] === mtime) {
          fn(cached[1]);
        } else {
          this.deleteIndex(doc);
          fn();
        }
      };
      req.onerror = function (event) {
        event.preventDefault();
        fn();
      };
    });
  }

  /**
   * @param {Doc} doc
   * @param {number} mtime The build the index was fetched for.
   * @param {unknown} index
   * @param {boolean} [_retry] Internal: whether a failure may bump the schema and try again.
   */
  storeIndex(doc, mtime, index, _retry) {
    if (_retry == null) {
      _retry = true;
    }
    this.db((db) => {
      try {
        this.indexesStore(db, "readwrite").put([mtime, index], doc.slug);
      } catch (error) {
        // The store is missing for anyone whose database predates it. Bumping
        // the schema creates it (see onUpgradeNeeded).
        if (this.onMissingIndexesStore(error) && _retry) {
          setTimeout(() => this.storeIndex(doc, mtime, index, false), 0);
        }
      }
    });
  }

  /** @param {Doc} doc */
  deleteIndex(doc) {
    this.db((db) => {
      try {
        this.indexesStore(db, "readwrite").delete(doc.slug);
      } catch (error) {
        this.onMissingIndexesStore(error);
      }
    });
  }

  /**
   * Takes in the indexes an earlier version of the app cached in localStorage,
   * and clears out everything it left there. Called from the boot, once the
   * enabled docs are known — opening the database before that would upgrade it
   * into having no doc stores at all.
   *
   * An index is dropped from localStorage whether or not it makes it into the
   * database: it is a cache, and the doc falls back to the network.
   *
   * @param {boolean} [_retry] Internal: whether a failure may bump the schema
   *   and try again.
   */
  migrateIndexes(_retry) {
    if (_retry == null) {
      _retry = true;
    }

    const keys = app.localStorage
      .keys()
      .filter((key) => !DB.NOT_INDEXES.includes(key));

    if (keys.length === 0) {
      return;
    }

    this.db((db) => {
      let store;
      try {
        store = this.indexesStore(db, "readwrite");
      } catch (error) {
        // Wait for the store rather than sweeping without one, which would
        // drop every index instead of moving it.
        if (this.onMissingIndexesStore(error) && _retry) {
          setTimeout(() => this.migrateIndexes(false), 0);
          return;
        }
      }

      // One at a time, rather than reading every index into memory first.
      for (var key of keys) {
        const cached = app.localStorage.get(key);
        if (store && isCachedIndex(cached)) {
          try {
            store.put(cached, key);
          } catch (error) {}
        }
        app.localStorage.del(key);
      }
    });
  }

  /**
   * @param {IDBDatabase | undefined} db
   * @param {IDBTransactionMode} mode
   * @returns {IDBObjectStore} Throws when the database is missing, or hasn't
   *   got the store yet, which every caller treats as a cache miss.
   */
  indexesStore(db, mode) {
    return this.idbTransaction(db, {
      stores: [DB.INDEXES_STORE],
      mode,
    }).objectStore(DB.INDEXES_STORE);
  }

  /**
   * @param {{ name?: string }} error
   * @returns {boolean} Whether the store was the thing that was missing, in
   *   which case the schema has been bumped so that the next open creates it.
   */
  onMissingIndexesStore(error) {
    if (error?.name !== "NotFoundError") {
      return false;
    }
    this.migrate();
    return true;
  }

  /**
   * @param {Doc} doc
   * @returns {number | false | undefined} `undefined` when the cache isn't loaded yet.
   */
  cachedVersion(doc) {
    if (!this.cachedDocs) {
      return;
    }
    return this.cachedDocs[doc.slug] || false;
  }

  /**
   * @param {Doc[]} docs
   * @param {(versions: Record<string, number | false> | false) => void} fn
   */
  versions(docs, fn) {
    const versions = this.cachedVersions(docs);
    if (versions) {
      fn(versions);
      return;
    }

    return this.db((db) => {
      if (!db) {
        fn(false);
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: ["docs"],
        mode: "readonly",
      });
      txn.oncomplete = function () {
        fn(result);
      };
      const store = txn.objectStore("docs");
      var result = {};

      docs.forEach((doc) => {
        const req = store.get(doc.slug);
        req.onsuccess = function () {
          result[doc.slug] = req.result;
        };
        req.onerror = function (event) {
          event.preventDefault();
          result[doc.slug] = false;
        };
      });
    });
  }

  /**
   * @param {Doc[]} docs
   * @returns {Record<string, number | false> | undefined} `undefined` when the cache isn't loaded yet.
   */
  cachedVersions(docs) {
    if (!this.cachedDocs) {
      return;
    }
    const result = {};
    for (var doc of docs) {
      result[doc.slug] = this.cachedVersion(doc);
    }
    return result;
  }

  /**
   * Reads an entry's page, from the offline store when it is there and from
   * the network otherwise.
   *
   * @param {Entry} entry
   * @param {(html: string) => void} onSuccess
   * @param {() => void} onError
   * @returns {{ abort: () => void } | undefined} The pending request, when it
   *   went to the network.
   */
  load(entry, onSuccess, onError) {
    if (this.shouldLoadWithIDB(entry)) {
      this.loadWithIDB(entry, onSuccess, () =>
        this.loadWithXHR(entry, onSuccess, onError),
      );
      return;
    }
    return this.loadWithXHR(entry, onSuccess, onError);
  }

  /**
   * @param {Entry} entry
   * @param {(html: string) => void} onSuccess
   * @param {() => void} onError
   * @returns {{ abort: () => void }}
   */
  loadWithXHR(entry, onSuccess, onError) {
    return ajax({
      url: entry.fileUrl(),
      dataType: "html",
      success: onSuccess,
      error: onError,
    });
  }

  /**
   * @param {Entry} entry
   * @param {(html: string) => void} onSuccess
   * @param {() => void} onError Called when the page isn't stored, so the caller can fall back.
   */
  loadWithIDB(entry, onSuccess, onError) {
    return this.db((db) => {
      if (!db) {
        onError();
        return;
      }

      if (!db.objectStoreNames.contains(entry.doc.slug)) {
        onError();
        this.loadDocsCache(db);
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: [entry.doc.slug],
        mode: "readonly",
      });
      const store = txn.objectStore(entry.doc.slug);

      const req = store.get(entry.dbPath());
      req.onsuccess = function () {
        if (req.result) {
          onSuccess(req.result);
        } else {
          onError();
        }
      };
      req.onerror = function (event) {
        event.preventDefault();
        onError();
      };
      this.loadDocsCache(db);
    });
  }

  /**
   * Reads every doc's stored `mtime` into memory, once per session.
   *
   * @param {IDBDatabase} db
   */
  loadDocsCache(db) {
    if (this.cachedDocs) {
      return;
    }
    this.cachedDocs = {};

    const txn = this.idbTransaction(db, {
      stores: ["docs"],
      mode: "readonly",
    });
    txn.oncomplete = () => {
      setTimeout(() => this.checkForCorruptedDocs(), 50);
    };

    const req = txn.objectStore("docs").openCursor();
    req.onsuccess = (event) => {
      const cursor = /** @type {IDBEvent} */ (event).target.result;
      if (!cursor) {
        return;
      }
      this.cachedDocs[cursor.key] = cursor.value;
      cursor.continue();
    };
    req.onerror = function (event) {
      event.preventDefault();
    };
  }

  /** Looks for docs whose store is missing its index page, and drops them. */
  checkForCorruptedDocs() {
    this.db((db) => {
      let slug;
      this.corruptedDocs = [];
      const docs = (() => {
        const result = [];
        for (var key in this.cachedDocs) {
          var value = this.cachedDocs[key];
          if (value) {
            result.push(key);
          }
        }
        return result;
      })();
      if (docs.length === 0) {
        return;
      }

      for (slug of docs) {
        if (!app.docs.findBy("slug", slug)) {
          this.corruptedDocs.push(slug);
        }
      }

      for (slug of this.corruptedDocs) {
        $.arrayDelete(docs, slug);
      }

      if (docs.length === 0) {
        setTimeout(() => this.deleteCorruptedDocs(), 0);
        return;
      }

      const txn = this.idbTransaction(db, {
        stores: docs,
        mode: "readonly",
        ignoreError: false,
      });
      txn.oncomplete = () => {
        if (this.corruptedDocs.length > 0) {
          setTimeout(() => this.deleteCorruptedDocs(), 0);
        }
      };

      for (var doc of docs) {
        txn.objectStore(doc).get("index").onsuccess = (event) => {
          if (!/** @type {IDBEvent} */ (event).target.result) {
            this.corruptedDocs.push(
              /** @type {IDBObjectStore} */ (
                /** @type {IDBEvent} */ (event).target.source
              ).name,
            );
          }
        };
      }
    });
  }

  /** Forgets the docs `checkForCorruptedDocs` found. */
  deleteCorruptedDocs() {
    this.db((db) => {
      let doc;
      const txn = this.idbTransaction(db, {
        stores: ["docs"],
        mode: "readwrite",
        ignoreError: false,
      });
      const store = txn.objectStore("docs");
      while ((doc = this.corruptedDocs.pop())) {
        this.cachedDocs[doc] = false;
        store.delete(doc);
      }
    });
    Raven.captureMessage("corruptedDocs", {
      level: "info",
      extra: { docs: this.corruptedDocs.join(",") },
    });
  }

  /**
   * @param {Entry} entry
   * @returns {boolean} Whether the entry's doc is installed.
   */
  shouldLoadWithIDB(entry) {
    return (
      this.useIndexedDB && (!this.cachedDocs || this.cachedDocs[entry.doc.slug])
    );
  }

  /**
   * @param {IDBDatabase} db
   * @param {DBTransactionOptions} options
   * @returns {IDBTransaction}
   */
  idbTransaction(db, options) {
    app.lastIDBTransaction = [options.stores, options.mode];
    const txn = db.transaction(options.stores, options.mode);
    if (options.ignoreError !== false) {
      txn.onerror = function (event) {
        event.preventDefault();
      };
    }
    if (options.ignoreAbort !== false) {
      txn.onabort = function (event) {
        event.preventDefault();
      };
    }
    return txn;
  }

  /** Deletes the whole database. */
  reset() {
    try {
      indexedDB?.deleteDatabase(DB.NAME);
    } catch (error) {}
  }

  /**
   * @returns {boolean} Whether IndexedDB can be used at all. Replaced by its
   *   own result in the constructor.
   */
  useIndexedDB() {
    try {
      if (!app.isSingleDoc() && window.indexedDB) {
        return true;
      } else {
        this.reason = "not_supported";
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  /** Bumps the user's schema version, forcing the next open to upgrade. */
  migrate() {
    app.settings.set("schema", this.userVersion() + 1);
  }

  /** @param {number} version */
  setUserVersion(version) {
    app.settings.set("schema", version);
  }

  /** @returns {number} */
  userVersion() {
    return app.settings.get("schema");
  }
}

/**
 * @param {unknown} value
 * @returns {boolean} Whether `value` is an index as the old localStorage cache
 *   stored it: the mtime it was fetched at, and the index itself.
 */
const isCachedIndex = (value) =>
  Array.isArray(value) && value.length === 2 && typeof value[0] === "number";
