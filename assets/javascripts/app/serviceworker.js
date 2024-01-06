app.ServiceWorker = class ServiceWorker extends Events {
  static isEnabled() {
    return !!navigator.serviceWorker && app.config.service_worker_enabled;
  }

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

  update() {
    if (!this.registration) {
      return;
    }
    this.notifyUpdate = true;
    return this.registration.update().catch(() => {});
  }

  updateInBackground() {
    if (!this.registration) {
      return;
    }
    this.notifyUpdate = false;
    return this.registration.update().catch(() => {});
  }

  reload() {
    return this.updateInBackground().then(() => app.reboot());
  }

  updateRegistration(registration) {
    this.registration = registration;
    $.on(this.registration, "updatefound", () => this.onUpdateFound());
  }

  onUpdateFound() {
    if (this.installingRegistration) {
      $.off(this.installingRegistration, "statechange", this.onStateChange);
    }
    this.installingRegistration = this.registration.installing;
    $.on(this.installingRegistration, "statechange", this.onStateChange);
  }

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

  onUpdateReady() {
    if (this.notifyUpdate) {
      this.trigger("updateready");
    }
  }
};
