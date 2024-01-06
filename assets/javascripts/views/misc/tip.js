/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/misc/notif

const Cls = (app.views.Tip = class Tip extends app.views.Notif {
  static initClass() {
    this.className = '_notif _notif-tip';
  
    this.defautOptions =
      {autoHide: false};
  }

  render() {
    this.html(this.tmpl(`tip${this.type}`));
  }
});
Cls.initClass();
