/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/misc/notif

const Cls = (app.views.Updates = class Updates extends app.views.Notif {
  static initClass() {
    this.className += ' _notif-news';
  
    this.defautOptions =
      {autoHide: 30000};
  }

  init() {
    this.lastUpdateTime = this.getLastUpdateTime();
    this.updatedDocs = this.getUpdatedDocs();
    this.updatedDisabledDocs = this.getUpdatedDisabledDocs();
    if ((this.updatedDocs.length > 0) || (this.updatedDisabledDocs.length > 0)) { this.show(); }
    this.markAllAsRead();
  }

  render() {
    this.html(app.templates.notifUpdates(this.updatedDocs, this.updatedDisabledDocs));
  }

  getUpdatedDocs() {
    if (!this.lastUpdateTime) { return []; }
    return Array.from(app.docs.all()).filter((doc) => doc.mtime > this.lastUpdateTime);
  }

  getUpdatedDisabledDocs() {
    if (!this.lastUpdateTime) { return []; }
    return (() => {
      const result = [];
      for (var doc of Array.from(app.disabledDocs.all())) {         if ((doc.mtime > this.lastUpdateTime) && app.docs.findBy('slug_without_version', doc.slug_without_version)) {
          result.push(doc);
        }
      }
      return result;
    })();
  }

  getLastUpdateTime() {
    return app.settings.get('version');
  }

  markAllAsRead() {
    app.settings.set('version', app.config.env === 'production' ? app.config.version : Math.floor(Date.now() / 1000));
  }
});
Cls.initClass();
