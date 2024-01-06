// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/list/paginated_list

app.views.EntryList = class EntryList extends app.views.PaginatedList {
  static initClass() {
    this.tagName = "div";
    this.className = "_list _list-sub";
  }

  constructor(entries) {
    super(...arguments);
    this.entries = entries;
  }

  init() {
    this.renderPaginated();
    this.activate();
  }

  render(entries) {
    return this.tmpl("sidebarEntry", entries);
  }
};
app.views.EntryList.initClass();
