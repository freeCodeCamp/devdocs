//= require views/misc/notif

app.views.Tip = class Tip extends app.views.Notif {
  static className = "_notif _notif-tip";

  static defautOptions = { autoHide: false };

  render() {
    this.html(this.tmpl(`tip${this.type}`));
  }
};
