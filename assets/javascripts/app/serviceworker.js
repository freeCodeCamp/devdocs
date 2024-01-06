// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (app.ServiceWorker = class ServiceWorker {
  static initClass() {
    $.extend(this.prototype, Events);
  }

  static isEnabled() {
    return !!navigator.serviceWorker && app.config.service_worker_enabled;
  }

  constructor() {
    this.onUpdateFound = this.onUpdateFound.bind(this);
    this.onStateChange = this.onStateChange.bind(this);
    this.registration = null;
    this.notifyUpdate = true;

    navigator.serviceWorker.register(app.config.service_worker_path, {scope: '/'})
      .then(
        registration => this.updateRegistration(registration),
        error => console.error('Could not register service worker:', error));
  }

  update() {
    if (!this.registration) { return; }
    this.notifyUpdate = true;
    return this.registration.update().catch(function() {});
  }

  updateInBackground() {
    if (!this.registration) { return; }
    this.notifyUpdate = false;
    return this.registration.update().catch(function() {});
  }

  reload() {
    return this.updateInBackground().then(() => app.reboot());
  }

  updateRegistration(registration) {
    this.registration = registration;
    $.on(this.registration, 'updatefound', this.onUpdateFound);
  }

  onUpdateFound() {
    if (this.installingRegistration) { $.off(this.installingRegistration, 'statechange', this.onStateChange()); }
    this.installingRegistration = this.registration.installing;
    $.on(this.installingRegistration, 'statechange', this.onStateChange);
  }

  onStateChange() {
    if (this.installingRegistration && (this.installingRegistration.state === 'installed') && navigator.serviceWorker.controller) {
      this.installingRegistration = null;
      this.onUpdateReady();
    }
  }

  onUpdateReady() {
    if (this.notifyUpdate) { this.trigger('updateready'); }
  }
});
Cls.initClass();
