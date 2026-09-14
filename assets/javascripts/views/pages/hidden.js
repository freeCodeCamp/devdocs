// @ts-check

import { $ } from "../../lib/util.js";
import { Notice } from "../misc/notice.js";
import { View } from "../view.js";
/** @import { Entry } from "../../models/entry.js" */

/**
 * An entry belonging to a doc that isn't enabled: shown with a notice, and
 * with its links opened outside the app.
 */
export class HiddenPage extends View {
  static events = { click: "onClick" };

  /**
   * @param {HTMLElement} el
   * @param {Entry} entry
   */
  constructor(el, entry) {
    super(el);
    this.entry = entry;
  }

  /** @inheritdoc */
  init() {
    this.notice = new Notice("disabledDoc");
    this.addSubview(this.notice);
    this.activate();
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const link = $.closestLink(event.target, this.el);
    if (link) {
      $.stopEvent(event);
      $.popup(link);
    }
  }
}
