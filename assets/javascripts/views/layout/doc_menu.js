// @ts-check

import { searchEntries } from "../../lib/doc_search.js";
import { $ } from "../../lib/util.js";
import { View } from "../view.js";
/** @import { Context } from "../../lib/page.js" */
/** @import { Doc } from "../../models/doc.js" */

/**
 * The opened doc's button, next to the search box. It shows the doc's icon
 * and opens a panel with the doc's contents (its types) and a box that
 * searches only that doc. The box isn't focused when the panel opens, so the
 * keyboard doesn't pop up on phones.
 */
export class DocMenu extends View {
  static className = "_doc-menu";

  static events = {
    click: "onClick",
    input: "onInput",
    keydown: "onKeydown",
    // The search box is in a form so that typing in it stays there: the
    // shortcuts send typing outside a form to the main search.
    submit: "onSubmit",
  };

  static routes = { after: "afterRoute" };

  /** @inheritdoc */
  init() {
    /** @type {Doc | null} */
    this.doc = null;
    this.html(this.tmpl("docMenu"));
    this.button = /** @type {HTMLButtonElement} */ (this.find("._doc-menu-btn"));
    this.icon = /** @type {HTMLElement} */ (this.find("._doc-menu-icon"));
    this.panel = /** @type {HTMLElement} */ (this.find("._doc-menu-panel"));
    this.title = /** @type {HTMLAnchorElement} */ (this.find("._doc-menu-title"));
    this.input = /** @type {HTMLInputElement} */ (this.find("._doc-menu-input"));
    this.list = /** @type {HTMLElement} */ (this.find("._doc-menu-list"));

    $("._search").insertAdjacentElement("afterend", this.el);
    $.on(document.body, "click", (event) => this.onGlobalClick(event));
  }

  /**
   * Shows the button for the doc of the page, or hides it on other pages.
   *
   * @param {string} route
   * @param {Context} context
   */
  afterRoute(route, context) {
    this.close();
    const doc = context.doc || null;
    if (doc === this.doc) {
      return;
    }
    this.doc = doc;
    this.button.hidden = !doc;
    if (doc) {
      this.icon.className = `_doc-menu-icon _icon-${doc.icon}`;
      const label = `Contents of ${doc.fullName}`;
      this.button.title = label;
      this.button.setAttribute("aria-label", label);
      this.title.textContent = doc.fullName;
      this.title.href = doc.fullPath();
    }
  }

  open() {
    if (!this.doc) {
      return;
    }
    this.input.value = "";
    this.showContents();
    this.panel.hidden = false;
    this.button.setAttribute("aria-expanded", "true");
  }

  close() {
    if (this.panel.hidden) {
      return;
    }
    this.panel.hidden = true;
    this.button.setAttribute("aria-expanded", "false");
  }

  /** Lists the doc's types, or the entries matching the search. */
  showContents() {
    const doc = this.doc;
    const query = this.input.value;
    if (query.trim()) {
      const entries = doc.entries ? searchEntries(doc.entries.all(), query) : [];
      this.list.innerHTML = this.tmpl("docMenuResults", doc, entries);
    } else {
      this.list.innerHTML = this.tmpl("docMenuTypes", doc, doc.types ? doc.types.all() : []);
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if ($.eventTarget(event).closest("._doc-menu-btn")) {
      $.stopEvent(event);
      if (this.panel.hidden) {
        this.open();
      } else {
        this.close();
      }
    } else if ($.closestLink(event.target, this.el)) {
      // The router follows the link; the panel closes when it arrives.
      /** @type {HTMLElement} */ (event.target).blur?.();
    }
  }

  /** @param {Event} event */
  onInput(event) {
    if (event.target === this.input) {
      this.showContents();
    }
  }

  /** @param {Event} event */
  onSubmit(event) {
    $.stopEvent(event);
  }

  /** @param {KeyboardEvent} event */
  onKeydown(event) {
    if (event.key === "Escape" && !this.panel.hidden) {
      $.stopEvent(event);
      this.close();
      this.button.focus();
    } else if (event.key === "Enter" && event.target === this.input) {
      // Enter opens the first match.
      $.stopEvent(event);
      /** @type {HTMLAnchorElement | null} */ (this.list.querySelector("a"))?.click();
    }
  }

  /** Closes the panel on a click anywhere else. @param {MouseEvent} event */
  onGlobalClick(event) {
    if (!this.panel.hidden && !this.el.contains(/** @type {Node} */ (event.target))) {
      this.close();
    }
  }
}
