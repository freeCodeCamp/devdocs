/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS202: Simplify dynamic range loops
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function() {
  let PER_PAGE = undefined;
  const Cls = (app.views.PaginatedList = class PaginatedList extends app.View {
    static initClass() {
      PER_PAGE = app.config.max_results;
    }

    constructor(data) {
      let base;
      this.onClick = this.onClick.bind(this);
      this.data = data;
      if (((base = this.constructor.events || (this.constructor.events = {}))).click == null) { base.click = 'onClick'; }
      super(...arguments);
    }

    renderPaginated() {
      this.page = 0;

      if (this.totalPages() > 1) {
        this.paginateNext();
      } else {
        this.html(this.renderAll());
      }
    }

    // render: (dataSlice) -> implemented by subclass

    renderAll() {
      return this.render(this.data);
    }

    renderPage(page) {
      return this.render(this.data.slice(((page - 1) * PER_PAGE), (page * PER_PAGE)));
    }

    renderPageLink(count) {
      return this.tmpl('sidebarPageLink', count);
    }

    renderPrevLink(page) {
      return this.renderPageLink((page - 1) * PER_PAGE);
    }

    renderNextLink(page) {
      return this.renderPageLink(this.data.length - (page * PER_PAGE));
    }

    totalPages() {
      return Math.ceil(this.data.length / PER_PAGE);
    }

    paginate(link) {
      $.lockScroll(link.nextSibling || link.previousSibling, () => {
        $.batchUpdate(this.el, () => {
          if (link.nextSibling) { this.paginatePrev(link); } else { this.paginateNext(link); }
        });
      });
    }

    paginateNext() {
      if (this.el.lastChild) { this.remove(this.el.lastChild); } // remove link
      if (this.page >= 2) { this.hideTopPage(); } // keep previous page into view
      this.page++;
      this.append(this.renderPage(this.page));
      if (this.page < this.totalPages()) { this.append(this.renderNextLink(this.page)); }
    }

    paginatePrev() {
      this.remove(this.el.firstChild); // remove link
      this.hideBottomPage();
      this.page--;
      this.prepend(this.renderPage(this.page - 1)); // previous page is offset by one
      if (this.page >= 3) { this.prepend(this.renderPrevLink(this.page - 1)); }
    }

    paginateTo(object) {
      const index = this.data.indexOf(object);
      if (index >= PER_PAGE) {
        for (let i = 0, end = Math.floor(index / PER_PAGE), asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) { this.paginateNext(); }
      }
    }

    hideTopPage() {
      const n = this.page <= 2 ?
        PER_PAGE
      :
        PER_PAGE + 1; // remove link
      for (let i = 0, end = n, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) { this.remove(this.el.firstChild); }
      this.prepend(this.renderPrevLink(this.page));
    }

    hideBottomPage() {
      const n = this.page === this.totalPages() ?
        (this.data.length % PER_PAGE) || PER_PAGE
      :
        PER_PAGE + 1; // remove link
      for (let i = 0, end = n, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) { this.remove(this.el.lastChild); }
      this.append(this.renderNextLink(this.page - 1));
    }

    onClick(event) {
      const target = $.eventTarget(event);
      if (target.tagName === 'SPAN') { // link
        $.stopEvent(event);
        this.paginate(target);
      }
    }
  });
  Cls.initClass();
  return Cls;
})();
