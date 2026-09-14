// @ts-check

import { app } from "../../app/app.js";
import { $ } from "../../lib/util.js";
import { ListFocus } from "../list/list_focus.js";
import { ListSelect } from "../list/list_select.js";
import { View } from "../view.js";
/** @import { Context } from "../../lib/page.js" */
/** @import { Doc } from "../../models/doc.js" */
/** @import { Entry } from "../../models/entry.js" */
/** @import { Search } from "../search/search.js" */
/** @import { Sidebar } from "./sidebar.js" */

/**
 * The search results in the sidebar.
 *
 * Results arrive in batches as the searcher works through the entries, so
 * only the first batch clears the list and moves the focus.
 */
export class Results extends View {
  static className = "_list";

  static events = { click: "onClick" };

  static routes = { after: "afterRoute" };

  /**
   * @param {Sidebar} sidebar
   * @param {Search} search
   */
  constructor(sidebar, search) {
    super();
    this.sidebar = sidebar;
    this.search = search;
    this.init0(); // needs this.search
    this.refreshElements();
  }

  /** Also empties the list. */
  deactivate() {
    if (super.deactivate()) {
      this.empty();
    }
  }

  /** Called by the constructor once `search` is set. */
  init0() {
    this.addSubview((this.listFocus = new ListFocus(this.el)));
    this.addSubview((this.listSelect = new ListSelect(this.el)));

    this.search
      .on("results", (entries, flags) =>
        this.onResults(
          /** @type {Entry[]} */ (entries),
          /** @type {{ initialResults?: boolean, urlSearch?: boolean }} */ (flags),
        ),
      )
      .on("noresults", () => this.onNoResults())
      .on("clear", () => this.onClear());
  }

  /**
   * @param {Entry[]} entries One batch of matches.
   * @param {{ initialResults?: boolean, urlSearch?: boolean }} flags
   *   `initialResults` marks the first batch of a search; `urlSearch` means
   *   the query came from the URL, so the first result is opened rather than
   *   just focused.
   */
  onResults(entries, flags) {
    if (flags.initialResults) {
      this.listFocus?.blur();
    }
    if (flags.initialResults) {
      this.empty();
    }
    this.append(this.tmpl("sidebarResult", entries));

    if (flags.initialResults) {
      if (flags.urlSearch) {
        this.openFirst();
      } else {
        this.focusFirst();
      }
    }
  }

  /** Shows the empty state. */
  onNoResults() {
    this.html(this.tmpl("sidebarNoResults"));
  }

  /** Empties the list. */
  onClear() {
    this.empty();
  }

  /** Focuses the first result, unless on a phone. */
  focusFirst() {
    if (!app.isMobile()) {
      this.listFocus?.focusOnNextFrame(this.el.firstElementChild);
    }
  }

  /** Follows the first result. */
  openFirst() {
    /** @type {HTMLElement | null} */ (this.el.firstElementChild)?.click();
  }

  /** @param {Doc} doc The doc that was just enabled from a result. */
  onDocEnabled(doc) {
    app.router.show(doc.fullPath());
    return this.sidebar.onDocEnabled();
  }

  /**
   * @param {string} route
   * @param {Context} context
   */
  afterRoute(route, context) {
    if (route === "entry") {
      this.listSelect.selectByHref(context.entry.fullPath());
    } else {
      this.listSelect.deselect();
    }
  }

  /**
   * Enables the doc behind a result's Enable button.
   *
   * @param {ViewMouseEvent} event
   */
  onClick(event) {
    if (event.which !== 1) {
      return;
    }
    const slug = $.eventTarget(event).getAttribute("data-enable");
    if (slug) {
      $.stopEvent(event);
      const doc = app.disabledDocs.findBy("slug", slug);
      if (doc) {
        return app.enableDoc(doc, this.onDocEnabled.bind(this, doc), $.noop);
      }
    }
  }
}
