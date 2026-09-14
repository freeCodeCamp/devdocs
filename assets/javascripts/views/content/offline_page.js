app.views.OfflinePage = class OfflinePage extends app.View {
  static className = "_static";

  static events = {
    click: "onClick",
    change: "onChange",
  };

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
    }
  }

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

  renderDoc(doc, status) {
    return app.templates.render("offlineDoc", doc, status);
  }

  getTitle() {
    return "Offline";
  }

  refreshLinks() {
    for (var action of ["install", "update", "uninstall"]) {
      this.find(`[data-action-all='${action}']`).classList[
        this.find(`[data-action='${action}']`) ? "add" : "remove"
      ]("_show");
    }
  }

  docByEl(el) {
    let slug;
    while (!(slug = el.getAttribute("data-slug"))) {
      el = el.parentNode;
    }
    return app.docs.findBy("slug", slug);
  }

  docEl(doc) {
    return this.find(`[data-slug='${doc.slug}']`);
  }

  onRoute(context) {
    this.render();
  }

  onClick(event) {
    let el = $.eventTarget(event);
    let action = el.getAttribute("data-action");
    if (action) {
      const doc = this.docByEl(el);
      if (action === "update") {
        action = "install";
      }
      doc[action](
        this.onInstallSuccess.bind(this, doc),
        this.onInstallError.bind(this, doc),
        this.onInstallProgress.bind(this, doc)
      );
      el.parentNode.innerHTML = `${el.textContent.replace(/e$/, "")}ing…`;
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
    }
  }

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

  onInstallError(doc) {
    if (!this.activated) {
      return;
    }
    const el = this.docEl(doc);
    if (el) {
      el.lastElementChild.textContent = "Error";
    }
  }

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

  onChange(event) {
    if (event.target.name === "autoUpdate") {
      app.settings.set("manualUpdate", !event.target.checked);
    }
  }

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

  requestPersistence() {
    navigator.storage
      .persist()
      .then((success) => this.onPersistenceRequestCompleted(success))
      .catch((exception) =>
        this.onPersistenceRequestCompleted(false, exception)
      );
  }

  onPersistenceRequestCompleted(success, exception) {
    if (success) {
      this.render();
    } else {
      this.html(this.tmpl("persistenceError", exception));
    }
  }
};
