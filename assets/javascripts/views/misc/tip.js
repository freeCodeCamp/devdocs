// @ts-check

//= require views/misc/notif

/** A one-off hint, shown once per user and dismissed by clicking it. */
class Tip extends Notif {
  static className = "_notif _notif-tip";

  static defautOptions = { autoHide: false };

  /** @inheritdoc */
  render() {
    this.html(this.tmpl(`tip${this.type}`));
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Tip = Tip;
