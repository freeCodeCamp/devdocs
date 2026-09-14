// @ts-check

import { app } from "./app.js";
import { ajax } from "../lib/ajax.js";
import { $ } from "../lib/util.js";
import { Notif } from "../views/misc/notif.js";

/** Watches for new builds of the app and new versions of the installed docs. */
export class UpdateChecker {
  /** Starts watching for new builds and checks the docs once. */
  constructor() {
    this.lastCheck = Date.now();

    $.on(window, "focus", () => this.onFocus());
    if (app.serviceWorker) {
      app.serviceWorker.on("updateready", () => this.onUpdateReady());
    }

    setTimeout(() => this.checkDocs(), 0);
  }

  /**
   * Checks whether a new build of the app is available, by asking the service
   * worker to update or, without one, by re-requesting the app bundle.
   */
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

  /** Offers the user a reload. */
  onUpdateReady() {
    new Notif("UpdateReady", { autoHide: null });
  }

  /** Updates the installed docs, or offers to when updates are manual. */
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

  /** Offers the user a doc update. */
  onDocsUpdateReady() {
    new Notif("UpdateDocs", { autoHide: null });
  }

  /** Re-checks when the tab is focused, at most every six hours. */
  onFocus() {
    if (Date.now() - this.lastCheck > 21600e3) {
      this.lastCheck = Date.now();
      this.check();
    }
  }
}
