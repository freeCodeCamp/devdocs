//= require views/misc/notif

app.views.Updates = class Updates extends app.views.Notif {
  static className = "_notif _notif-news";

  static defautOptions = { autoHide: 30000 };

  init0() {
    this.lastUpdateTime = this.getLastUpdateTime();
    this.updatedDocs = this.getUpdatedDocs();
    this.updatedDisabledDocs = this.getUpdatedDisabledDocs();
    if (this.updatedDocs.length > 0 || this.updatedDisabledDocs.length > 0) {
      this.show();
    }
    this.markAllAsRead();
  }

  render() {
    this.html(
      app.templates.notifUpdates(this.updatedDocs, this.updatedDisabledDocs),
    );
  }

  getUpdatedDocs() {
    if (!this.lastUpdateTime) {
      return [];
    }
    return Array.from(app.docs.all()).filter(
      (doc) => doc.mtime > this.lastUpdateTime,
    );
  }

  getUpdatedDisabledDocs() {
    if (!this.lastUpdateTime) {
      return [];
    }
    const result = [];
    for (var doc of Array.from(app.disabledDocs.all())) {
      if (
        doc.mtime > this.lastUpdateTime &&
        app.docs.findBy("slug_without_version", doc.slug_without_version)
      ) {
        result.push(doc);
      }
    }
    return result;
  }

  getLastUpdateTime() {
    return app.settings.get("version");
  }

  markAllAsRead() {
    app.settings.set(
      "version",
      app.config.env === "production"
        ? app.config.version
        : Math.floor(Date.now() / 1000),
    );
  }
};
