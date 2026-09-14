// @ts-check

import { Notif } from "./notif.js";

/** A one-off hint, shown once per user and dismissed by clicking it. */
export class Tip extends Notif {
  static className = "_notif _notif-tip";

  static defautOptions = { autoHide: false };

  /** @inheritdoc */
  render() {
    this.html(this.tmpl(`tip${this.type}`));
  }
}
