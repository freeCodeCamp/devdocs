// @ts-check

import { $ } from "../../lib/util.js";
import { EntryList } from "./entry_list.js";
import { View } from "../view.js";
/** @import { Doc } from "../../models/doc.js" */
/** @import { Entry } from "../../models/entry.js" */

/**
 * A doc's types, shown under it in the sidebar.
 *
 * Each type's entries are only built when the type is expanded, and thrown
 * away when it is collapsed — a doc can hold tens of thousands of entries.
 */
export class TypeList extends View {
  static tagName = "div";
  static className = "_list _list-sub";

  static events = {
    open: "onOpen",
    close: "onClose",
  };

  /** @param {Doc} doc */
  constructor(doc) {
    super();
    this.doc = doc;
    this.init0(); // needs this.doc
    this.refreshElements();
  }

  /** Called by the constructor once `doc` is set. */
  init0() {
    this.lists = {};
    this.render();
    this.activate();
  }

  /** Also activates the entry lists already built. */
  activate() {
    if (super.activate()) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.activate();
      }
    }
  }

  /** Also deactivates them. */
  deactivate() {
    if (super.deactivate()) {
      for (var slug in this.lists) {
        var list = this.lists[slug];
        list.deactivate();
      }
    }
  }

  /** @returns {unknown} */
  render() {
    let html = "";
    for (var group of this.doc.types.groups()) {
      html += this.tmpl("sidebarType", group);
    }
    return this.html(html);
  }

  /**
   * Builds the expanded type's entry list.
   *
   * @param {ViewEvent} event
   */
  onOpen(event) {
    $.stopEvent(event);
    const type = this.doc.types.findBy(
      "slug",
      event.target.getAttribute("data-slug"),
    );

    if (type && !this.lists[type.slug]) {
      this.lists[type.slug] = new EntryList(type.entries());
      $.after(event.target, this.lists[type.slug].el);
    }
  }

  /**
   * Throws away the collapsed type's entry list.
   *
   * @param {ViewEvent} event
   */
  onClose(event) {
    $.stopEvent(event);
    const type = this.doc.types.findBy(
      "slug",
      event.target.getAttribute("data-slug"),
    );

    if (type && this.lists[type.slug]) {
      this.lists[type.slug].detach();
      delete this.lists[type.slug];
    }
  }

  /**
   * Renders as far as the entry, so that it can be revealed.
   *
   * @param {Entry} model
   */
  paginateTo(model) {
    if (model.type) {
      this.lists[model.getType().slug]?.paginateTo(model);
    }
  }
}
