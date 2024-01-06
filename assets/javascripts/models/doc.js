app.models.Doc = class Doc extends app.Model {
  // Attributes: name, slug, type, version, release, db_size, mtime, links

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
    return `${app.indexHost()}/${this.slug}/${app.config.index_filename}?${
      this.mtime
    }`;
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
    let entry;
    if (hash && (entry = this.entries.findBy("path", `${path}#${hash}`))) {
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
    let data;
    if (!(data = this._getCache())) {
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
    let data;
    if (!(data = app.localStorage.get(this.slug))) {
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
      app.db.store(this, data, onSuccess, error);
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

  isOutdated(status) {
    if (!status) {
      return false;
    }
    const isInstalled = status.installed || app.settings.get("autoInstall");
    return isInstalled && this.mtime !== status.mtime;
  }
};
