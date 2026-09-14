// @ts-check

import { PaginatedList } from "../list/paginated_list.js";
/** @import { Entry } from "../../models/entry.js" */

/** The entries of one type, shown under it in the sidebar. */
export class EntryList extends PaginatedList {
  static tagName = "div";
  static className = "_list _list-sub";

  /** @param {Entry[]} entries */
  constructor(entries) {
    super(entries);
    this.entries = entries;
    this.init0(); // needs this.data from PaginatedList
    this.refreshElements();
  }

  /** Called by the constructor once `data` is set. */
  init0() {
    this.renderPaginated();
    this.activate();
  }

  /**
   * @param {Entry[]} entries One page of entries.
   * @returns {string}
   */
  render(entries) {
    return this.tmpl("sidebarEntry", entries);
  }
}
