// @ts-check

import { $ } from "../../lib/util.js";
import { View } from "../view.js";

/**
 * The selected row of a list — the entry currently being read, which stays
 * marked as the user moves the focus around.
 *
 * Selecting and deselecting emit `select` and `deselect` on the row.
 */
export class ListSelect extends View {
  static activeClass = "active";

  static events = { click: "onClick" };

  /** Also clears the selection. */
  deactivate() {
    if (super.deactivate()) {
      this.deselect();
    }
  }

  /** @param {HTMLElement} el The row to select, deselecting whatever was selected. */
  select(el) {
    this.deselect();
    if (el) {
      el.classList.add(this.statics().activeClass);
      $.trigger(el, "select");
    }
  }

  /** Clears the selection. */
  deselect() {
    const selection = this.getSelection();
    if (selection) {
      selection.classList.remove(this.statics().activeClass);
      $.trigger(selection, "deselect");
    }
  }

  /** @param {string} href */
  selectByHref(href) {
    if (this.getSelection()?.getAttribute("href") !== href) {
      this.select(this.find(`a[href='${href}']`));
    }
  }

  /** Selects the row pointing at the current page. */
  selectCurrent() {
    this.selectByHref(location.pathname + location.hash);
  }

  /** @returns {HTMLElement | undefined} The selected row. */
  getSelection() {
    return this.findByClass(this.statics().activeClass);
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.which !== 1 || event.metaKey || event.ctrlKey) {
      return;
    }
    const target = $.eventTarget(event);
    if (target.tagName === "A") {
      this.select(target);
    }
  }
}
