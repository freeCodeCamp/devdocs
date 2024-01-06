//= require views/list/paginated_list

app.views.EntryList = class EntryList extends app.views.PaginatedList {
  static tagName = "div";
  static className = "_list _list-sub";

  constructor(entries) {
    super(...arguments);
    this.entries = entries;
    this.init0(); // needs this.data from PaginatedList
    this.refreshElements();
  }

  init0() {
    this.renderPaginated();
    this.activate();
  }

  render(entries) {
    return this.tmpl("sidebarEntry", entries);
  }
};
