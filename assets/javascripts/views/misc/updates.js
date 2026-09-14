// @ts-check

//= require views/misc/notif

/**
 * The notification listing the docs that gained a new release since the
 * user last saw it.
 */
app.views.Updates = class Updates extends app.views.Notif {
  static className = "_notif _notif-news";

  static defautOptions = { autoHide: 30000 };

  /** @inheritdoc */
  init0() {
    this.lastUpdateTime = this.getLastUpdateTime();
    this.updatedDocs = this.getUpdatedDocs();
    this.updatedDisabledDocs = this.getUpdatedDisabledDocs();
    if (this.updatedDocs.length > 0 || this.updatedDisabledDocs.length > 0) {
      this.show();
    }
    this.markAllAsRead();
  }

  /** @inheritdoc */
  render() {
    this.html(
      app.templates.notifUpdates(this.updatedDocs, this.updatedDisabledDocs),
    );
  }

  /** @returns {unknown[]} Enabled docs built since the last time updates were shown. */
  getUpdatedDocs() {
    if (!this.lastUpdateTime) {
      return [];
    }
    return Array.from(app.docs.all()).filter(
      (doc) => doc.mtime > this.lastUpdateTime,
    );
  }

  /**
   * @returns {unknown[]} Disabled docs built since then, but only where another
   *   version of the same doc is enabled.
   */
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

  /** @returns {number} When updates were last shown, as a Unix timestamp. */
  getLastUpdateTime() {
    return app.settings.get("version");
  }

  /** Records that the user has seen the current set of releases. */
  markAllAsRead() {
    app.settings.set(
      "version",
      app.config.env === "production"
        ? app.config.version
        : Math.floor(Date.now() / 1000),
    );
  }
};
