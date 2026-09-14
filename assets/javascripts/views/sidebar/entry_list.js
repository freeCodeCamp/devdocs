// @ts-check

//= require views/list/paginated_list

/** The entries of one type, shown under it in the sidebar. */
app.views.EntryList = class EntryList extends app.views.PaginatedList {
  static tagName = "div";
  static className = "_list _list-sub";

  /** @param {unknown[]} entries */
  constructor(entries) {
    super(...arguments);
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
   * @param {unknown[]} entries One page of entries.
   * @returns {string}
   */
  render(entries) {
    return this.tmpl("sidebarEntry", entries);
  }
};
