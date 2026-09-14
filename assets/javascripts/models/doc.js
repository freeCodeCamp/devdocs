app.models.Doc = class Doc extends app.Model {
  // Attributes: name, slug, type, version, release, db_size, mtime, links

  static NUMBERED_VERSION_RGX = /^\d+(\.\d+)*$/;

  constructor() {
    super(...arguments);
    this.reset(this);
    this.slug_without_version = this.slug.split("~")[0];
    this.fullName = `${this.name}` + (this.version ? ` ${this.version}` : "");
    this.icon = this.slug_without_version;
    if (this.version) {
      this.short_version = this.version.split(" ")[0];
    }
    this.text = this.toEntry().text;
  }

  reset(data) {
    this.resetEntries(data.entries);
    this.resetTypes(data.types);
  }

  resetEntries(entries) {
    this.entries = new app.collections.Entries(entries);
    this.entries.each((entry) => {
      return (entry.doc = this);
    });
  }

  resetTypes(types) {
    this.types = new app.collections.Types(types);
    this.types.each((type) => {
      return (type.doc = this);
    });
  }

  fullPath(path) {
    if (path == null) {
      path = "";
    }
    if (path[0] !== "/") {
      path = `/${path}`;
    }
    return `/${this.slug}${path}`;
  }

  fileUrl(path) {
    return `${app.config.docs_origin}${this.fullPath(path)}?${this.mtime}`;
  }

  dbUrl() {
    return `${app.config.docs_origin}/${this.slug}/${app.config.db_filename}?${this.mtime}`;
  }

  indexUrl() {
    return `${app.config.docs_origin}/${this.slug}/${
      app.config.index_filename
    }?${this.mtime}`;
  }

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

  clearCache() {
    app.localStorage.del(this.slug);
  }

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

  _setCache(data) {
    app.localStorage.set(this.slug, [this.mtime, data]);
  }

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

  getInstallStatus(callback) {
    app.db.version(this, (value) =>
      callback({ installed: !!value, mtime: value }),
    );
  }

  // Whether the doc holds a numbered version of its documentation (e.g. "3.9"),
  // as opposed to a variant (e.g. "10 LTS" or "Python"), which can't be
  // ordered. An empty version means the doc holds the latest version
  // (e.g. `angular`), whereas docs without a version aren't versioned at all.
  hasNumberedVersion() {
    return (
      this.version === "" || Doc.NUMBERED_VERSION_RGX.test(this.version || "")
    );
  }

  // Compares numbered versions (e.g. "3.9" is older than "3.12").
  // An empty version means the latest version and is newer than any other.
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

  // Returns the doc holding the latest version of the same documentation among
  // `docs`, or the doc itself when there is none.
  findLatestVersion(docs) {
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

  isOutdated(status) {
    if (!status) {
      return false;
    }
    const isInstalled = status.installed || app.settings.get("autoInstall");
    return isInstalled && this.mtime !== status.mtime;
  }
};
