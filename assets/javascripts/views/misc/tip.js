// @ts-check

//= require views/misc/notif

/** A one-off hint, shown once per user and dismissed by clicking it. */
app.views.Tip = class Tip extends app.views.Notif {
  static className = "_notif _notif-tip";

  static defautOptions = { autoHide: false };

  /** @inheritdoc */
  render() {
    this.html(this.tmpl(`tip${this.type}`));
  }
};
