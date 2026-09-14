// @ts-check

import { $ } from "../../lib/util.js";
import { BasePage } from "./base.js";

/** The SQLite pages' show/hide toggles. */
export class SqlitePage extends BasePage {
  static events = { click: "onClick" };

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const id = event.target.getAttribute("data-toggle");
    if (!id) {
      return;
    }
    const el = this.find(`#${id}`);
    if (!el) {
      return;
    }
    $.stopEvent(event);
    if (el.style.display === "none") {
      el.style.display = "block";
      event.target.textContent = "hide";
    } else {
      el.style.display = "none";
      event.target.textContent = "show";
    }
  }
}
