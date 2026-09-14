// @ts-check

import { config } from "../../app/config.js";
import { $ } from "../../lib/util.js";
import { View } from "../view.js";

/**
 * A list too long to render at once: only a window of `PER_PAGE` rows is in
 * the document, with links at either end to extend it.
 *
 * Subclasses implement `render(dataSlice)`.
 */
export class PaginatedList extends View {
  static PER_PAGE = config.max_results;

  /** @param {unknown[]} data Every row, rendered a page at a time. */
  constructor(data) {
    super();
    this.data = data;
    this.statics().events = this.statics().events || {};
    if (this.statics().events.click == null) {
      this.statics().events.click = "onClick";
    }
  }

  /** Renders the first page, or the whole list when it fits on one. */
  renderPaginated() {
    this.page = 0;

    if (this.totalPages() > 1) {
      this.paginateNext();
    } else {
      this.html(this.renderAll());
    }
  }

  // render: (dataSlice) -> implemented by subclass

  /** @returns {string} Every row. */
  renderAll() {
    return this.render(this.data);
  }

  /**
   * @param {number} page One-based.
   * @returns {string}
   */
  renderPage(page) {
    return this.render(
      this.data.slice(
        (page - 1) * PaginatedList.PER_PAGE,
        page * PaginatedList.PER_PAGE,
      ),
    );
  }

  /**
   * @param {number} count How many rows the link would add.
   * @returns {string}
   */
  renderPageLink(count) {
    return this.tmpl("sidebarPageLink", count);
  }

  /**
   * @param {number} page
   * @returns {string} The link that prepends the page before `page`.
   */
  renderPrevLink(page) {
    return this.renderPageLink((page - 1) * PaginatedList.PER_PAGE);
  }

  /**
   * @param {number} page
   * @returns {string} The link that appends the page after `page`.
   */
  renderNextLink(page) {
    return this.renderPageLink(
      this.data.length - page * PaginatedList.PER_PAGE,
    );
  }

  /** @returns {number} */
  totalPages() {
    return Math.ceil(this.data.length / PaginatedList.PER_PAGE);
  }

  /**
   * Extends the list in the direction the link points, holding the scroll
   * position so that the rows under the pointer don't move.
   *
   * @param {HTMLElement} link
   */
  paginate(link) {
    $.lockScroll(
      /** @type {HTMLElement} */ (link.nextSibling || link.previousSibling),
      () => {
        $.batchUpdate(this.el, () => {
          if (link.nextSibling) {
            this.paginatePrev();
          } else {
            this.paginateNext();
          }
        });
      },
    );
  }

  /** Appends the page after the current one. */
  paginateNext() {
    if (this.el.lastChild) {
      this.remove(/** @type {HTMLElement} */ (this.el.lastChild));
    } // remove link
    if (this.page >= 2) {
      this.hideTopPage();
    } // keep previous page into view
    this.page++;
    this.append(this.renderPage(this.page));
    if (this.page < this.totalPages()) {
      this.append(this.renderNextLink(this.page));
    }
  }

  /** Prepends the page before the current one. */
  paginatePrev() {
    this.remove(/** @type {HTMLElement} */ (this.el.firstChild)); // remove link
    this.hideBottomPage();
    this.page--;
    this.prepend(this.renderPage(this.page - 1)); // previous page is offset by one
    if (this.page >= 3) {
      this.prepend(this.renderPrevLink(this.page - 1));
    }
  }

  /**
   * Renders whichever page holds `object`.
   *
   * @param {unknown} object A row of `data`.
   */
  paginateTo(object) {
    const index = this.data.indexOf(object);
    if (index >= PaginatedList.PER_PAGE) {
      for (
        let i = 0, end = Math.floor(index / PaginatedList.PER_PAGE);
        i < end;
        i++
      ) {
        this.paginateNext();
      }
    }
  }

  /** Drops the page above the window, replacing it with a link. */
  hideTopPage() {
    const n =
      this.page <= 2 ? PaginatedList.PER_PAGE : PaginatedList.PER_PAGE + 1; // remove link
    for (let i = 0, end = n; i < end; i++) {
      this.remove(/** @type {HTMLElement} */ (this.el.firstChild));
    }
    this.prepend(this.renderPrevLink(this.page));
  }

  /** Drops the page below the window, replacing it with a link. */
  hideBottomPage() {
    const n =
      this.page === this.totalPages()
        ? this.data.length % PaginatedList.PER_PAGE || PaginatedList.PER_PAGE
        : PaginatedList.PER_PAGE + 1; // remove link
    for (let i = 0, end = n; i < end; i++) {
      this.remove(/** @type {HTMLElement} */ (this.el.lastChild));
    }
    this.append(this.renderNextLink(this.page - 1));
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const target = $.eventTarget(event);
    if (target.tagName === "SPAN") {
      // link
      $.stopEvent(event);
      this.paginate(target);
    }
  }
}
