// @ts-check

import { $ } from "../../lib/util.js";
import { BasePage } from "./base.js";

/** The support tables' "show all" buttons, which expand a table in place. */
export class SupportTablesPage extends BasePage {
  static events = { click: "onClick" };

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (!event.target.classList.contains("show-all")) {
      return;
    }
    $.stopEvent(event);

    let el = event.target;
    while (el.tagName !== "TABLE") {
      el = el.parentElement;
    }
    el.classList.add("show-all");
  }
}
