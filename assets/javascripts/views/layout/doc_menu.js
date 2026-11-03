// @ts-check

import { searchEntries } from "../../lib/doc_search.js";
import { $ } from "../../lib/util.js";
import { View } from "../view.js";
/** @import { Context } from "../../lib/page.js" */
/** @import { Doc } from "../../models/doc.js" */
/** @import { Type } from "../../models/type.js" */

/**
 * The opened doc's contents menu, pinned to the top left of the page. Its
 * button names the doc; the panel lists the doc's sections, each opening to
 * its entries, over the page, with a box that searches only that doc. The box
 * isn't focused when the panel opens, so the keyboard doesn't pop up on phones.
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
    /** @type {Type[]} */
    this.types = [];
    this.html(this.tmpl("docMenu"));
    this.el.hidden = true;
    this.button = /** @type {HTMLButtonElement} */ (this.find("._doc-menu-btn"));
    this.icon = /** @type {HTMLElement} */ (this.find("._doc-menu-icon"));
    this.name = /** @type {HTMLElement} */ (this.find("._doc-menu-name"));
    this.panel = /** @type {HTMLElement} */ (this.find("._doc-menu-panel"));
    this.title = /** @type {HTMLAnchorElement} */ (this.find("._doc-menu-title"));
    this.input = /** @type {HTMLInputElement} */ (this.find("._doc-menu-input"));
    this.list = /** @type {HTMLElement} */ (this.find("._doc-menu-list"));

    this.container = $("._container");
    this.container.prepend(this.el);
    $.on(document.body, "click", (event) => this.onGlobalClick(event));
  }

  /**
   * Shows the menu for the doc of the page, or hides it on other pages.
   *
   * @param {string} route
   * @param {Context} context
   */
  afterRoute(route, context) {
    this.close();
    const doc = context.doc || null;
    // Pages leave room for the button at their top while it's there.
    this.container.classList.toggle("_has-doc-menu", !!doc);
    this.el.hidden = !doc;
    if (!doc || doc === this.doc) {
      this.doc = doc;
      return;
    }
    this.doc = doc;
    this.icon.className = `_doc-menu-icon _icon-${doc.icon}`;
    this.name.textContent = doc.fullName;
    const label = `Contents of ${doc.fullName}`;
    this.button.title = label;
    this.button.setAttribute("aria-label", label);
    this.title.textContent = doc.fullName;
    this.title.href = doc.fullPath();
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

  /** Lists the doc's sections, or the entries matching the search. */
  showContents() {
    const doc = this.doc;
    const query = this.input.value;
    if (query.trim()) {
      const entries = doc.entries ? searchEntries(doc.entries.all(), query) : [];
      this.list.innerHTML = this.tmpl("docMenuResults", doc, entries);
    } else {
      // In the sidebar's order: guides first, appendices last.
      this.types = doc.types
        ? /** @type {Type[]} */ (doc.types.groups().flat())
        : [];
      this.list.innerHTML = this.tmpl("docMenuTypes", doc, this.types);
    }
  }

  /**
   * Opens or closes a section's list of entries, built the first time.
   *
   * @param {HTMLElement} row
   */
  toggleType(row) {
    const entries = /** @type {HTMLElement} */ (row.nextElementSibling);
    const isOpen = row.getAttribute("aria-expanded") === "true";
    if (!isOpen && !entries.childElementCount) {
      const type = this.types[Number(row.getAttribute("data-type-index"))];
      entries.innerHTML = type ? this.tmpl("docMenuEntry", type.entries()) : "";
    }
    row.setAttribute("aria-expanded", String(!isOpen));
    entries.hidden = isOpen;
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const target = $.eventTarget(event);
    const row = /** @type {HTMLElement | null} */ (target.closest("._doc-menu-row"));
    if (target.closest("._doc-menu-btn")) {
      $.stopEvent(event);
      if (this.panel.hidden) {
        this.open();
      } else {
        this.close();
      }
    } else if (row) {
      $.stopEvent(event);
      this.toggleType(row);
    }
    // A link is followed by the router; the panel closes when it arrives.
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
