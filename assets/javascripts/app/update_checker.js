app.UpdateChecker = class UpdateChecker {
  constructor() {
    this.lastCheck = Date.now();

    $.on(window, "focus", () => this.onFocus());
    if (app.serviceWorker) {
      app.serviceWorker.on("updateready", () => this.onUpdateReady());
    }

    setTimeout(() => this.checkDocs(), 0);
  }

  check() {
    if (app.serviceWorker) {
      app.serviceWorker.update();
    } else {
      ajax({
        url: $('script[src*="application"]').getAttribute("src"),
        dataType: "application/javascript",
        error: (_, xhr) => {
          if (xhr.status === 404) {
            return this.onUpdateReady();
          }
        },
      });
    }
  }

  onUpdateReady() {
    new app.views.Notif("UpdateReady", { autoHide: null });
  }

  checkDocs() {
    if (!app.settings.get("manualUpdate")) {
      app.docs.updateInBackground();
    } else {
      app.docs.checkForUpdates((i) => {
        if (i > 0) {
          return this.onDocsUpdateReady();
        }
      });
    }
  }

  onDocsUpdateReady() {
    new app.views.Notif("UpdateDocs", { autoHide: null });
  }

  onFocus() {
    if (Date.now() - this.lastCheck > 21600e3) {
      this.lastCheck = Date.now();
      this.check();
    }
  }
};
