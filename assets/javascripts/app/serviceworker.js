// @ts-check

/**
 * Registers the service worker and reports when a new one is waiting.
 *
 * Emits `updateready` when an update is ready to take over, but only for
 * checks the user asked for.
 */
class AppServiceWorker extends Events {
  /** @returns {boolean} Whether the browser supports service workers and the build enables them. */
  static isEnabled() {
    return !!navigator.serviceWorker && app.config.service_worker_enabled;
  }

  /** Registers the worker and starts watching for updates. */
  constructor() {
    super();
    this.onStateChange = this.onStateChange.bind(this);
    this.registration = null;
    this.notifyUpdate = true;

    navigator.serviceWorker
      .register(app.config.service_worker_path, { scope: "/" })
      .then(
        (registration) => this.updateRegistration(registration),
        (error) => console.error("Could not register service worker:", error),
      );
  }

  /**
   * Checks for a new worker, notifying the user if one is ready.
   *
   * @returns {Promise<ServiceWorkerRegistration | void> | undefined}
   */
  update() {
    if (!this.registration) {
      return;
    }
    this.notifyUpdate = true;
    return this.registration.update().catch(() => {});
  }

  /**
   * Checks for a new worker without notifying the user.
   *
   * @returns {Promise<ServiceWorkerRegistration | void> | undefined}
   */
  updateInBackground() {
    if (!this.registration) {
      return;
    }
    this.notifyUpdate = false;
    return this.registration.update().catch(() => {});
  }

  /** @returns {Promise<void>} Resolves once the app has been rebooted onto the new worker. */
  reload() {
    return this.updateInBackground().then(() => app.reboot());
  }

  /** @param {ServiceWorkerRegistration} registration */
  updateRegistration(registration) {
    this.registration = registration;
    $.on(this.registration, "updatefound", () => this.onUpdateFound());
  }

  /** Watches the worker being installed, so that its readiness can be reported. */
  onUpdateFound() {
    if (this.installingRegistration) {
      $.off(this.installingRegistration, "statechange", this.onStateChange);
    }
    this.installingRegistration = this.registration.installing;
    $.on(this.installingRegistration, "statechange", this.onStateChange);
  }

  /** Reports readiness once the new worker is installed and one is already in control. */
  onStateChange() {
    if (
      this.installingRegistration &&
      this.installingRegistration.state === "installed" &&
      navigator.serviceWorker.controller
    ) {
      this.installingRegistration = null;
      this.onUpdateReady();
    }
  }

  /** Emits `updateready`, unless the check was a background one. */
  onUpdateReady() {
    if (this.notifyUpdate) {
      this.trigger("updateready");
    }
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.ServiceWorker = AppServiceWorker;
