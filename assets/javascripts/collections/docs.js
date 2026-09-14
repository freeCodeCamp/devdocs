// @ts-check

/** Every doc the app knows about, enabled or not. */
app.collections.Docs = class Docs extends app.Collection {
  static model = "Doc";
  static NORMALIZE_VERSION_RGX = /\.(\d)$/;
  static NORMALIZE_VERSION_SUB = ".0$1";

  // Load models concurrently.
  // It's not pretty but I didn't want to import a promise library only for this.
  static CONCURRENCY = 3;

  /**
   * @param {string} slug With or without a version.
   * @returns {any} The doc, or `undefined`.
   */
  findBySlug(slug) {
    return (
      this.findBy("slug", slug) || this.findBy("slug_without_version", slug)
    );
  }
  /**
   * Orders by name, then by version with the newest first. Sorts in place.
   *
   * @returns {any[]}
   */
  sort() {
    return this.models.sort((a, b) => {
      if (a.name === b.name) {
        if (
          !a.version ||
          a.version.replace(
            Docs.NORMALIZE_VERSION_RGX,
            Docs.NORMALIZE_VERSION_SUB,
          ) >
            b.version.replace(
              Docs.NORMALIZE_VERSION_RGX,
              Docs.NORMALIZE_VERSION_SUB,
            )
        ) {
          return -1;
        } else {
          return 1;
        }
      } else if (a.name.toLowerCase() > b.name.toLowerCase()) {
        return 1;
      } else {
        return -1;
      }
    });
  }
  /**
   * Loads every doc's index, `CONCURRENCY` at a time. `onError` is called at
   * most once, with the first failure.
   *
   * @param {() => void} onComplete
   * @param {((args: any[]) => void) | null} onError
   * @param {DocLoadOptions} [options]
   */
  load(onComplete, onError, options) {
    let i = 0;

    var next = () => {
      if (i < this.models.length) {
        this.models[i].load(next, fail, options);
      } else if (i === this.models.length + Docs.CONCURRENCY - 1) {
        onComplete();
      }
      i++;
    };

    var fail = function (...args) {
      if (onError) {
        onError(args);
        onError = null;
      }
      next();
    };

    for (let j = 0, end = Docs.CONCURRENCY; j < end; j++) {
      next();
    }
  }

  /** Drops every doc's cached index. */
  clearCache() {
    for (var doc of this.models) {
      doc.clearCache();
    }
  }

  /**
   * Removes every doc's offline database, one at a time.
   *
   * @param {() => void} callback
   */
  uninstall(callback) {
    let i = 0;
    var next = () => {
      if (i < this.models.length) {
        this.models[i++].uninstall(next, next);
      } else {
        callback();
      }
    };
    next();
  }

  /** @param {(statuses: Record<string, InstallStatus> | undefined) => void} callback */
  getInstallStatuses(callback) {
    app.db.versions(this.models, (statuses) => {
      if (statuses) {
        for (var key in statuses) {
          var value = statuses[key];
          statuses[key] = { installed: !!value, mtime: value };
        }
      }
      callback(statuses);
    });
  }

  /** @param {(count: number) => void} callback Given the number of outdated docs. */
  checkForUpdates(callback) {
    this.getInstallStatuses((statuses) => {
      let i = 0;
      if (statuses) {
        for (var slug in statuses) {
          var status = statuses[slug];
          if (this.findBy("slug", slug).isOutdated(status)) {
            i += 1;
          }
        }
      }
      callback(i);
    });
  }

  /** Reinstalls every doc whose offline copy is out of date. */
  updateInBackground() {
    this.getInstallStatuses((statuses) => {
      if (!statuses) {
        return;
      }
      for (var slug in statuses) {
        var status = statuses[slug];
        var doc = this.findBy("slug", slug);
        if (doc.isOutdated(status)) {
          doc.install($.noop, $.noop);
        }
      }
    });
  }
};
