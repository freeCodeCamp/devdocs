/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/list/paginated_list

const Cls = (app.views.EntryList = class EntryList extends app.views.PaginatedList {
  static initClass() {
    this.tagName = 'div';
    this.className = '_list _list-sub';
  }

  constructor(entries) { this.entries = entries; super(...arguments); }

  init() {
    this.renderPaginated();
    this.activate();
  }

  render(entries) {
    return this.tmpl('sidebarEntry', entries);
  }
});
Cls.initClass();
