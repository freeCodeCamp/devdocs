// @ts-check

import { app } from "../../app/app.js";
import { findCategory } from "../../app/categories.js";
import { config } from "../../app/config.js";
import { SynchronousSearcher } from "../../app/searcher.js";
import { $ } from "../../lib/util.js";
import { View } from "../view.js";
/** @import { App } from "../../app/app.js" */
/** @import { Context } from "../../lib/page.js" */
/** @import { Doc } from "../../models/doc.js" */

/**
 * The docs of a category, as a search scope.
 *
 * @typedef {object} CategoryScope
 * @property {string} id
 * @property {string} name
 * @property {{ all(): import("../../models/entry.js").Entry[] }} entries
 */

/**
 * Narrowing the search to one doc, or to the docs of one category.
 *
 * Typing a doc's name (or a category's, such as "Databases" or "db") and then
 * space or tab turns what was typed into a tag in front of the field, and the
 * rest of the query is then matched within that doc or category alone. A doc
 * scope can also come from the URL hash, or from arriving on a doc's page.
 *
 * Emits `change` with the new doc and the previous one; the doc is null for a
 * category.
 */
export class SearchScope extends View {
  static SEARCH_PARAM = config.search_param;

  static elements = {
    input: "._search-input",
    tag: "._search-tag",
  };

  static events = {
    click: "onClick",
    keydown: "onKeydown",
    textInput: "onTextInput",
  };

  static routes = { after: "afterRoute" };

  static HASH_RGX = new RegExp(`^#${SearchScope.SEARCH_PARAM}=(.+?) .`);

  /** @inheritdoc */
  init() {
    this.placeholder = this.input.getAttribute("placeholder");

    this.searcher = new SynchronousSearcher({
      fuzzy_min_length: 2,
      max_results: 1,
    });
    this.searcher.on("results", (results) =>
      this.onResults(/** @type {Doc[]} */ (results)),
    );
  }

  /**
   * @returns {Doc | CategoryScope | App} The doc or category the search is
   *   scoped to, or the app when it isn't scoped.
   */
  getScope() {
    return this.doc || this.category || app;
  }

  /** @returns {boolean} Whether the search is scoped to a doc. */
  isActive() {
    return !!this.doc;
  }

  /** @returns {boolean} Whether the search is scoped to a doc or a category. */
  isScoped() {
    return !!(this.doc || this.category);
  }

  /** @returns {string | undefined} The scoped doc's or category's name. */
  name() {
    return this.doc?.name || this.category?.name;
  }

  /**
   * Scopes to the category or doc `value` names, if it names one.
   *
   * @param {string} value
   * @param {boolean} [searchDisabled] Also match docs that aren't enabled,
   *   which then redirect rather than scope.
   */
  search(value, searchDisabled) {
    if (searchDisabled == null) {
      searchDisabled = false;
    }
    if (this.isScoped()) {
      return;
    }
    // A category's name, typed in full ("databases", "db"), comes before the
    // docs, whose names it would otherwise half-match.
    const category = findCategory(value);
    if (category && app.docs.all().some((doc) => doc.category === category.id)) {
      this.selectCategory(category);
      return;
    }
    this.searcher.find(app.docs.all(), "text", value);
    if (!this.doc && searchDisabled) {
      this.searcher.find(app.disabledDocs.all(), "text", value);
    }
  }

  /** Applies the scope encoded in the URL hash, if there is one. */
  searchUrl() {
    const value = this.extractHashValue();
    if (value) {
      this.search(value, true);
    }
  }

  /** @param {Doc[]} results */
  onResults(results) {
    const doc = results[0];
    if (!doc) {
      return;
    }
    if (app.docs.contains(doc)) {
      this.selectDoc(doc);
    } else {
      this.redirectToDoc(doc);
    }
  }

  /**
   * Scopes to the doc and shows its tag.
   *
   * @param {Doc} doc
   */
  selectDoc(doc) {
    const previousDoc = this.doc;
    if (doc === previousDoc) {
      return;
    }
    this.doc = doc;
    this.category = null;
    this.showTag(doc.fullName);
    this.trigger("change", this.doc, previousDoc);
  }

  /**
   * Scopes to the enabled docs of a category and shows its tag.
   *
   * @param {import("../../app/categories.js").Category} category
   */
  selectCategory(category) {
    const previousDoc = this.doc;
    const entries = app.docs
      .all()
      .filter((doc) => doc.category === category.id)
      .flatMap((doc) => [doc.toEntry(), ...doc.entries.all()]);
    this.doc = null;
    this.category = { id: category.id, name: category.name, entries: { all: () => entries } };
    this.showTag(category.name);
    this.trigger("change", null, previousDoc);
  }

  /**
   * Shows the scope's tag in front of the field, in place of what was typed
   * to choose it.
   *
   * @param {string} text
   */
  showTag(text) {
    this.tag.textContent = text;
    this.tag.style.display = "block";

    this.input.removeAttribute("placeholder");
    this.input.value = this.input.value.slice(this.input.selectionStart);
    this.input.style.paddingLeft = this.tag.offsetWidth + 10 + "px";

    $.trigger(this.input, "input");
  }

  /**
   * Navigates to a doc that isn't enabled, keeping the rest of the query.
   *
   * @param {Doc} doc
   */
  redirectToDoc(doc) {
    const { hash } = location;
    app.router.replaceHash("");
    location.assign(doc.fullPath() + hash);
  }

  /** Drops the scope and restores the field. */
  reset() {
    if (!this.isScoped()) {
      return;
    }
    const previousDoc = this.doc;
    this.doc = null;
    this.category = null;

    this.tag.textContent = "";
    this.tag.style.display = "none";

    this.input.setAttribute("placeholder", this.placeholder);
    this.input.style.paddingLeft = "";

    this.trigger("change", null, previousDoc);
  }

  /**
   * Tries to scope to whatever has been typed so far.
   *
   * @param {ViewEvent} event
   */
  doScopeSearch(event) {
    this.search(this.input.value.slice(0, this.input.selectionStart));
    if (this.isScoped()) {
      $.stopEvent(event);
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.target === this.tag) {
      this.reset();
      $.stopEvent(event);
    }
  }

  /** @param {ViewKeyboardEvent} event */
  onKeydown(event) {
    if (event.key === "Backspace") {
      if (this.isScoped() && this.input.selectionEnd === 0) {
        this.reset();
        $.stopEvent(event);
      }
    } else if (!this.isScoped() && this.input.value && !$.isChromeForAndroid()) {
      if (event.ctrlKey || event.metaKey || event.altKey || event.shiftKey) {
        return;
      }
      if (event.key === "Tab" || (event.key === " " && app.isMobile())) {
        this.doScopeSearch(event);
      }
    }
  }

  /**
   * Chrome for Android doesn't report space in `keydown`, so the scope is
   * applied from the text input event there instead.
   *
   * @param {ViewEvent & { data?: string }} event
   */
  onTextInput(event) {
    if (!$.isChromeForAndroid()) {
      return;
    }
    if (!this.isScoped() && this.input.value && event.data === " ") {
      this.doScopeSearch(event);
    }
  }

  /** @returns {string | undefined} The scope in the URL hash, which is removed from it. */
  extractHashValue() {
    const value = this.getHashValue();
    if (value) {
      const newHash = $.urlDecodeFragment(location.hash).replace(
        `#${SearchScope.SEARCH_PARAM}=${value} `,
        `#${SearchScope.SEARCH_PARAM}=`
      );
      app.router.replaceHash(newHash);
      return value;
    }
  }

  /** @returns {string | undefined} The scope in the URL hash, left in place. */
  getHashValue() {
    try {
      return SearchScope.HASH_RGX.exec($.urlDecodeFragment(location.hash))?.[1];
    } catch (error) {}
  }

  /**
   * @param {string} name
   * @param {Context} context
   */
  afterRoute(name, context) {
    if (!app.isSingleDoc() && context.init && context.doc) {
      this.selectDoc(context.doc);
    }
  }
}
