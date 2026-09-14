// @ts-check

/**
 * How a doc's index and database are fetched.
 *
 * @typedef {object} DocLoadOptions
 * @property {boolean} [readCache] Use the cached index instead of fetching, when it is current.
 * @property {boolean} [writeCache] Cache the fetched index.
 */

/**
 * Whether a doc's database is stored offline, and how old the copy is.
 *
 * @typedef {object} InstallStatus
 * @property {boolean} installed
 * @property {number | false} [mtime] The `mtime` the stored copy was built
 *   from, or `false` when it isn't installed.
 */

// A doc's own properties are declared in globals.d.ts: Model copies the
// manifest attributes on, so a field declaration here would run after
// `super()` and blank them out again.

/** One version of one documentation set. */
class Doc extends Model {
  static NUMBERED_VERSION_RGX = /^\d+(\.\d+)*$/;

  /**
   * @param {Record<string, unknown>} [attributes] Copied onto the doc by Model;
   *   the derived attributes are then worked out from them.
   */
  constructor(attributes) {
    super(attributes);
    this.reset(this);
    this.slug_without_version = this.slug.split("~")[0];
    this.fullName = `${this.name}` + (this.version ? ` ${this.version}` : "");
    this.icon = this.slug_without_version;
    if (this.version) {
      this.short_version = this.version.split(" ")[0];
    }
    this.text = this.toEntry().text;
  }

  /**
   * Reloads the entries and types from freshly fetched index data.
   *
   * @param {{ entries?: unknown, types?: unknown }} data Freshly fetched index
   *   data, or the doc itself when its attributes carry the index.
   */
  reset(data) {
    this.resetEntries(data.entries);
    this.resetTypes(data.types);
  }

  /** @param {unknown} [entries] */
  resetEntries(entries) {
    this.entries = new app.collections.Entries(
      /** @type {unknown[]} */ (entries),
    );
    this.entries.each((entry) => {
      return (entry.doc = this);
    });
  }

  /** @param {unknown} [types] */
  resetTypes(types) {
    this.types = new app.collections.Types(/** @type {unknown[]} */ (types));
    this.types.each((type) => {
      return (type.doc = this);
    });
  }

  /**
   * @param {string} [path] Relative to the doc.
   * @returns {string} The app path for the page.
   */
  fullPath(path) {
    if (path == null) {
      path = "";
    }
    if (path[0] !== "/") {
      path = `/${path}`;
    }
    return `/${this.slug}${path}`;
  }

  /**
   * @param {string} [path]
   * @returns {string} Where the page's HTML is served from.
   */
  fileUrl(path) {
    return `${app.config.docs_origin}${this.fullPath(path)}?${this.mtime}`;
  }

  /** @returns {string} Where the doc's offline database is served from. */
  dbUrl() {
    return `${app.config.docs_origin}/${this.slug}/${app.config.db_filename}?${this.mtime}`;
  }

  /** @returns {string} Where the doc's entry index is served from. */
  indexUrl() {
    return `${app.config.docs_origin}/${this.slug}/${
      app.config.index_filename
    }?${this.mtime}`;
  }

  /**
   * The entry standing for the doc itself, so that it can be searched for
   * by name. Built once and reused.
   *
   * @returns {Entry}
   */
  toEntry() {
    if (this.entry) {
      return this.entry;
    }
    this.entry = new app.models.Entry({
      doc: this,
      name: this.fullName,
      path: "index",
    });
    if (this.version) {
      this.entry.addAlias(this.name);
    }
    return this.entry;
  }

  /**
   * @param {string} path
   * @param {string} [hash] Preferred over `path` alone when it matches an entry.
   * @returns {Entry | undefined}
   */
  findEntryByPathAndHash(path, hash) {
    const entry = hash && this.entries.findBy("path", `${path}#${hash}`);
    if (entry) {
      return entry;
    } else if (path === "index") {
      return this.toEntry();
    } else {
      return this.entries.findBy("path", path);
    }
  }

  /**
   * Fetches the doc's entry index, or reads it from the cache.
   *
   * @param {() => void} onSuccess
   * @param {() => void} onError
   * @param {DocLoadOptions} [options]
   */
  load(onSuccess, onError, options) {
    if (options == null) {
      options = {};
    }
    if (options.readCache && this._loadFromCache(onSuccess)) {
      return;
    }

    const callback = (data) => {
      this.reset(data);
      onSuccess();
      if (options.writeCache) {
        this._setCache(data);
      }
    };

    return ajax({
      url: this.indexUrl(),
      success: callback,
      error: onError,
    });
  }

  /** Drops the cached index. */
  clearCache() {
    app.localStorage.del(this.slug);
  }

  /**
   * @param {() => void} onSuccess Called asynchronously, to match the network path.
   * @returns {boolean | undefined} `true` when the cache was used.
   */
  _loadFromCache(onSuccess) {
    const data = this._getCache();
    if (!data) {
      return;
    }

    const callback = () => {
      this.reset(data);
      onSuccess();
    };

    setTimeout(callback, 0);
    return true;
  }

  /** @returns {unknown} The cached index, or `undefined` when it is missing or stale. */
  _getCache() {
    const data = app.localStorage.get(this.slug);
    if (!data) {
      return;
    }

    if (data[0] === this.mtime) {
      return data[1];
    } else {
      this.clearCache();
      return;
    }
  }

  /** @param {unknown} data */
  _setCache(data) {
    app.localStorage.set(this.slug, [this.mtime, data]);
  }

  /**
   * Downloads the doc's database and stores it offline. Does nothing while an
   * install or uninstall is already running.
   *
   * @param {() => void} onSuccess
   * @param {() => void} onError
   * @param {(event: ProgressEvent) => void} [onProgress]
   */
  install(onSuccess, onError, onProgress) {
    if (this.installing) {
      return;
    }
    this.installing = true;

    const error = () => {
      this.installing = null;
      onError();
    };

    const success = (data) => {
      this.installing = null;
      app.db.store(this, data, this.mtime, onSuccess, error);
    };

    ajax({
      url: this.dbUrl(),
      success,
      error,
      progress: onProgress,
      timeout: 3600,
    });
  }

  /**
   * Removes the doc's offline database.
   *
   * @param {() => void} onSuccess
   * @param {() => void} onError
   */
  uninstall(onSuccess, onError) {
    if (this.installing) {
      return;
    }
    this.installing = true;

    const success = () => {
      this.installing = null;
      onSuccess();
    };

    const error = () => {
      this.installing = null;
      onError();
    };

    app.db.unstore(this, success, error);
  }

  /** @param {(status: InstallStatus) => void} callback */
  getInstallStatus(callback) {
    app.db.version(this, (value) =>
      callback({ installed: !!value, mtime: value }),
    );
  }

  /**
   * Whether the doc holds a numbered version of its documentation (e.g. "3.9"),
   * as opposed to a variant (e.g. "10 LTS" or "Python"), which can't be
   * ordered. An empty version means the doc holds the latest version
   * (e.g. `angular`), whereas docs without a version aren't versioned at all.
   *
   * @returns {boolean}
   */
  hasNumberedVersion() {
    return (
      this.version === "" || Doc.NUMBERED_VERSION_RGX.test(this.version || "")
    );
  }

  /**
   * Compares numbered versions (e.g. "3.9" is older than "3.12").
   * An empty version means the latest version and is newer than any other.
   *
   * @param {Doc} other
   * @returns {boolean}
   */
  isNewerVersionThan(other) {
    if (this.version === "" || other.version === "") {
      return this.version === "" && other.version !== "";
    }
    const version = this.version.split(".");
    const otherVersion = other.version.split(".");
    for (let i = 0; i < Math.max(version.length, otherVersion.length); i++) {
      const diff =
        (parseInt(version[i], 10) || 0) - (parseInt(otherVersion[i], 10) || 0);
      if (diff !== 0) {
        return diff > 0;
      }
    }
    return false;
  }

  /**
   * @param {Doc[]} docs
   * @returns {unknown} The doc holding the latest version of the same
   *   documentation among `docs`, or the doc itself when there is none.
   */
  findLatestVersion(docs) {
    /** @type {Doc} */
    let latest = this;
    if (!this.hasNumberedVersion()) {
      return latest;
    }
    for (var doc of docs) {
      if (
        doc.name === this.name &&
        doc.hasNumberedVersion() &&
        doc.isNewerVersionThan(latest)
      ) {
        latest = doc;
      }
    }
    return latest;
  }

  /**
   * @param {InstallStatus | undefined} status
   * @returns {boolean} Whether the offline copy is older than the served one.
   */
  isOutdated(status) {
    if (!status) {
      return false;
    }
    const isInstalled = status.installed || app.settings.get("autoInstall");
    return isInstalled && this.mtime !== status.mtime;
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.models.Doc = Doc;
