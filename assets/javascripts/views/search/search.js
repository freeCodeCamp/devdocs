// @ts-check

/**
 * The search field at the top of the sidebar.
 *
 * Owns the scope, runs the searcher, and keeps the query in the URL hash so
 * that a search can be linked to. Also offers handing the query to an external
 * search engine, scoped to the doc's own site where there is one.
 */
app.views.Search = class Search extends app.View {
  static SEARCH_PARAM = app.config.search_param;

  static el = "._search";
  static activeClass = "_search-active";

  static elements = {
    input: "._search-input",
    resetLink: "._search-clear",
  };

  static events = {
    input: "onInput",
    click: "onClick",
    submit: "onSubmit",
  };

  static shortcuts = {
    typing: "focus",
    altG: "google",
    altS: "stackoverflow",
    altD: "duckduckgo",
  };

  static routes = { after: "afterRoute" };

  static HASH_RGX = new RegExp(`^#${Search.SEARCH_PARAM}=(.*)`);

  /** @inheritdoc */
  init() {
    this.addSubview((this.scope = new app.views.SearchScope(this.el)));

    this.searcher = new app.Searcher();
    this.searcher
      .on("results", (results) => this.onResults(results))
      .on("end", () => this.onEnd());

    this.scope.on("change", () => this.onScopeChange());

    app.on("ready", () => this.onReady());
    $.on(window, "hashchange", () => this.searchUrl());
    $.on(window, "focus", (event) => this.onWindowFocus(event));
  }

  /** Puts the cursor in the field, unless the user turned autofocus off. */
  focus() {
    if (document.activeElement === this.input) {
      return;
    }
    if (app.settings.get("noAutofocus")) {
      return;
    }
    this.input.focus();
  }

  /** Focuses the field on load, except on phones and when another field has it. */
  autoFocus() {
    if (app.isMobile() || $.isAndroid() || $.isIOS()) {
      return;
    }
    if (document.activeElement?.tagName === "INPUT") {
      return;
    }
    if (app.settings.get("noAutofocus")) {
      return;
    }
    this.input.focus();
  }

  /** @param {ViewEvent} event */
  onWindowFocus(event) {
    if (event.target === window) {
      return this.autoFocus();
    }
  }

  /** @returns {unknown} The doc the search is scoped to, or `undefined`. */
  getScopeDoc() {
    if (this.scope.isActive()) {
      return this.scope.getScope();
    }
  }

  /**
   * Empties the field.
   *
   * @param {boolean} [force] Also drop the scope, even with a query still typed.
   */
  reset(force) {
    if (force || !this.input.value) {
      this.scope.reset();
    }
    this.el.reset();
    this.onInput();
    this.autoFocus();
  }

  /** Runs the query from the URL once the docs have loaded. */
  onReady() {
    this.value = "";
    this.delay(this.onInput);
  }

  /** Runs the search for whatever is now in the field. */
  onInput() {
    if (
      this.value == null || // ignore events pre-"ready"
      this.value === this.input.value
    ) {
      return;
    }
    this.value = this.input.value;

    if (this.value.length) {
      this.search();
    } else {
      this.clear();
    }
  }

  /**
   * @param {boolean} [url] Whether the query came from the URL hash, in which
   *   case the first result is opened rather than just focused.
   */
  search(url) {
    if (url == null) {
      url = false;
    }
    this.addClass(this.statics().activeClass);
    this.trigger("searching");

    this.hasResults = null;
    this.flags = { urlSearch: url, initialResults: true };
    this.searcher.find(this.scope.getScope().entries.all(), "text", this.value);
  }

  /** Runs the query in the URL hash. */
  searchUrl() {
    if (location.pathname === "/") {
      this.scope.searchUrl();
    } else if (!app.router.isIndex()) {
      return;
    }

    const value = this.extractHashValue();
    if (!value) {
      return;
    }
    this.input.value = this.value = value;
    this.input.setSelectionRange(value.length, value.length);
    this.search(true);
    return true;
  }

  /** Empties the results and tells the sidebar the search is over. */
  clear() {
    this.removeClass(this.statics().activeClass);
    this.trigger("clear");
  }

  /**
   * Hands the query to a search engine, in a new tab.
   *
   * @param {string} url The engine's search URL, with the query appended.
   */
  externalSearch(url) {
    let value = this.value;
    if (value) {
      if (this.scope.name()) {
        value = `${this.scope.name()} ${value}`;
      }
      $.popup(`${url}${encodeURIComponent(value)}`);
      this.reset();
    }
  }

  /** Searches Google. */
  google() {
    this.externalSearch("https://www.google.com/search?q=");
  }

  /** Searches Stack Overflow. */
  stackoverflow() {
    this.externalSearch("https://stackoverflow.com/search?q=");
  }

  /** Searches DuckDuckGo. */
  duckduckgo() {
    this.externalSearch("https://duckduckgo.com/?t=devdocs&q=");
  }

  /** @param {unknown[]} results One batch of matches. */
  onResults(results) {
    if (results.length) {
      this.hasResults = true;
    }
    this.trigger("results", results, this.flags);
    this.flags.initialResults = false;
  }

  /** Reports that the search finished with nothing, if it did. */
  onEnd() {
    if (!this.hasResults) {
      this.trigger("noresults");
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.target === this.resetLink) {
      $.stopEvent(event);
      this.reset();
    }
  }

  /** @param {ViewEvent} event */
  onSubmit(event) {
    $.stopEvent(event);
  }

  /** Re-runs the search against the new scope. */
  onScopeChange() {
    this.value = "";
    this.onInput();
  }

  /**
   * @param {string} name
   * @param {any} context
   */
  afterRoute(name, context) {
    if (app.shortcuts.eventInProgress?.name === "escape") {
      return;
    }
    if (!context.init && app.router.isIndex()) {
      this.reset(true);
    }
    if (context.hash) {
      this.delay(this.searchUrl);
    }
    requestAnimationFrame(() => this.autoFocus());
  }

  /** @returns {string | undefined} The query in the URL hash, which is removed from it. */
  extractHashValue() {
    const value = this.getHashValue();
    if (value != null) {
      app.router.replaceHash();
      return value;
    }
  }

  /** @returns {string | undefined} The query in the URL hash, left in place. */
  getHashValue() {
    try {
      return Search.HASH_RGX.exec($.urlDecodeFragment(location.hash))?.[1];
    } catch (error) {}
  }
};
