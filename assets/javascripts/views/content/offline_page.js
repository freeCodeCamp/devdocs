// @ts-check

/**
 * The offline page: installing and removing each doc's database, and backing
 * the whole lot up to a file.
 */
class OfflinePage extends app.View {
  static className = "_static";

  static events = {
    click: "onClick",
    change: "onChange",
  };

  /** Also empties the table. */
  deactivate() {
    if (super.deactivate()) {
      this.empty();
    }
  }

  /** Rebuilds the table from the docs and their install statuses. */
  render() {
    if (app.cookieBlocked) {
      this.html(this.tmpl("offlineError", "cookie_blocked"));
      return;
    }

    app.docs.getInstallStatuses((statuses) => {
      if (!this.activated) {
        return;
      }
      if (statuses === false) {
        this.html(this.tmpl("offlineError", app.db.reason, app.db.error));
      } else {
        this.checkPersistence((hasPersistence, isPersistent) => {
          if (!this.activated) {
            return;
          }
          let html = "";
          for (var doc of app.docs.all()) {
            html += this.renderDoc(doc, statuses[doc.slug]);
          }
          this.html(
            this.tmpl("offlinePage", html, hasPersistence, isPersistent)
          );
          this.refreshLinks();
        });
      }
    });
  }

  /**
   * @param {Doc} doc
   * @param {InstallStatus} status
   */
  renderDoc(doc, status) {
    return app.templates.render("offlineDoc", doc, status);
  }

  /** @returns {string} */
  getTitle() {
    return "Offline";
  }

  /** Re-reads the install statuses and rebuilds the table. */
  refreshLinks() {
    for (var action of ["install", "update", "uninstall"]) {
      this.find(`[data-action-all='${action}']`).classList[
        this.find(`[data-action='${action}']`) ? "add" : "remove"
      ]("_show");
    }
  }

  /**
   * @param {any} el A node inside a row.
   * @returns {Doc | undefined} The row's doc.
   */
  docByEl(el) {
    let slug;
    while (!(slug = el.getAttribute("data-slug"))) {
      el = el.parentNode;
    }
    return app.docs.findBy("slug", slug);
  }

  /**
   * @param {Doc} doc
   * @returns {any} The doc's row.
   */
  docEl(doc) {
    return this.find(`[data-slug='${doc.slug}']`);
  }

  /** @param {unknown} context */
  onRoute(context) {
    this.render();
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    let el = $.eventTarget(event);
    let action = el.getAttribute("data-action");
    if (action === "export") {
      this.exportDoc(this.docByEl(el), el);
    } else if (action) {
      const doc = this.docByEl(el);
      if (action === "update") {
        action = "install";
      }
      doc[action](
        this.onInstallSuccess.bind(this, doc),
        this.onInstallError.bind(this, doc),
        this.onInstallProgress.bind(this, doc)
      );
      el.parentElement.innerHTML = `${el.textContent.replace(/e$/, "")}ing…`;
    } else if (
      (action =
        el.getAttribute("data-action-all") ||
        el.parentElement.getAttribute("data-action-all"))
    ) {
      if (action === "uninstall" && !window.confirm("Uninstall all docs?")) {
        return;
      }
      app.db.migrate();
      for (el of Array.from(this.findAll(`[data-action='${action}']`))) {
        $.click(el);
      }
    } else if (el.hasAttribute("data-enable-persistence")) {
      this.requestPersistence();
    } else if (el.hasAttribute("data-export-docs")) {
      this.exportDocs(app.docs.all());
    }
  }

  /** @param {Doc} doc */
  onInstallSuccess(doc) {
    if (!this.activated) {
      return;
    }
    doc.getInstallStatus((status) => {
      if (!this.activated) {
        return;
      }
      const el = this.docEl(doc);
      if (el) {
        el.outerHTML = this.renderDoc(doc, status);
        $.highlight(el, { className: "_highlight" });
        this.refreshLinks();
      }
    });
  }

  /** @param {Doc} doc */
  onInstallError(doc) {
    if (!this.activated) {
      return;
    }
    const el = this.docEl(doc);
    if (el) {
      el.lastElementChild.textContent = "Error";
    }
  }

  /**
   * @param {Doc} doc
   * @param {ProgressEvent} event
   */
  onInstallProgress(doc, event) {
    if (!this.activated || !event.lengthComputable) {
      return;
    }
    const el = this.docEl(doc);
    if (el) {
      const percentage = Math.round((event.loaded * 100) / event.total);
      el.lastElementChild.textContent = el.lastElementChild.textContent.replace(
        /(\s.+)?$/,
        ` (${percentage}%)`
      );
    }
  }

  /** @param {ViewInputEvent} event */
  onChange(event) {
    if (event.target.name === "autoUpdate") {
      app.settings.set("manualUpdate", !event.target.checked);
    } else if (event.target.name === "importDocs") {
      this.importDocs(event.target);
    }
  }

  /** Exports every installed doc to a file. */
  backup() {
    return this._backup || (this._backup = new app.OfflineBackup());
  }

  // Exports `docs` into a single file. Returns false when another backup is
  // already running, in which case `onDone` is never called.
  /**
   * @param {Doc[]} docs
   * @param {(success: boolean) => void} [onDone]
   * @returns {boolean} Whether the export started; it doesn't while one is
   *   already running.
   */
  exportDocs(docs, onDone) {
    if (this.backingUp) {
      return false;
    }
    this.backingUp = true;
    const backup = this.backup();

    const done = (html, isError, success) => {
      this.backingUp = false;
      if (!this.activated) {
        return;
      }
      this.setBackupStatus(html, isError);
      if (onDone) {
        onDone(success);
      }
    };

    backup.export(
      docs,
      (doc, i, total) =>
        this.setBackupStatus(
          this.tmpl("backupProgress", "Exporting", doc, i, total),
        ),
      (blob, count) => {
        $.download(blob, backup.filename(docs));
        done(this.tmpl("backupExported", count), false, true);
      },
      () => done(this.tmpl("backupError", "empty"), true, false),
    );

    return true;
  }

  /**
   * @param {Doc} doc
   * @param {any} el The doc's row.
   */
  exportDoc(doc, el) {
    const started = this.exportDocs([doc], (success) =>
      success ? this.onInstallSuccess(doc) : this.onInstallError(doc),
    );
    if (started) {
      el.parentElement.innerHTML = "Exporting\u2026";
    }
  }

  /** @param {any} input The file field the backup was chosen with. */
  importDocs(input) {
    const file = input.files[0];
    input.value = ""; // so that picking the same file again fires a change event

    if (this.backingUp) {
      return;
    }
    this.backingUp = true;

    this.backup().import(
      file,
      (doc, i, total) =>
        this.setBackupStatus(
          this.tmpl("backupProgress", "Importing", doc, i, total),
        ),
      (result) => {
        this.backingUp = false;
        // Newly enabled docs have no index in memory, so the session stays
        // inconsistent until the app reboots, whether the page is still
        // being shown or not.
        if (result.enabled > 0) {
          this.delay(() => app.reboot(), this.activated ? 2000 : 0);
        }
        if (!this.activated) {
          return;
        }
        this.setBackupStatus(
          this.tmpl("backupImported", result),
          result.failed.length > 0,
        );
        // Nothing was enabled: refresh the rows that changed, which keeps
        // the message a re-render would wipe.
        if (result.enabled === 0) {
          for (var doc of result.docs) {
            this.onInstallSuccess(doc);
          }
        }
      },
      (reason) => {
        this.backingUp = false;
        this.setBackupStatus(this.tmpl("backupError", reason), true);
      },
    );
  }

  /**
   * @param {string} html
   * @param {boolean} [isError]
   */
  setBackupStatus(html, isError) {
    const el = this.find("#_offline-backup-status");
    if (el) {
      el.innerHTML = `<p class="_note${isError ? " _note-red" : ""}">${html}`;
    }
  }

  /** @param {(hasPersistence: boolean, isPersistent: boolean) => void} callback */
  checkPersistence(callback) {
    if (navigator.storage && navigator.storage.persisted) {
      navigator.storage
        .persisted()
        .then((persisted) => callback(true, persisted))
        .catch(() => callback(false, false));
    } else {
      callback(false, false);
    }
  }

  /** Asks the browser not to evict the offline data. */
  requestPersistence() {
    navigator.storage
      .persist()
      .then((success) => this.onPersistenceRequestCompleted(success))
      .catch((exception) =>
        this.onPersistenceRequestCompleted(false, exception)
      );
  }

  /**
   * @param {boolean} success
   * @param {unknown} [exception]
   */
  onPersistenceRequestCompleted(success, exception) {
    if (!this.activated) {
      return;
    }
    const note = this.find("#_offline-persistence-note");
    if (!note) {
      return;
    }
    // Granting persistence retires the note, which is what a fresh render of
    // the page would produce; the disappearing button is the confirmation.
    note.innerHTML = success ? "" : this.tmpl("persistenceError", exception);
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.OfflinePage = OfflinePage;
