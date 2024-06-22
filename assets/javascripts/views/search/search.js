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

  focus() {
    if (document.activeElement === this.input) {
      return;
    }
    if (app.settings.get("noAutofocus")) {
      return;
    }
    this.input.focus();
  }

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

  onWindowFocus(event) {
    if (event.target === window) {
      return this.autoFocus();
    }
  }

  getScopeDoc() {
    if (this.scope.isActive()) {
      return this.scope.getScope();
    }
  }

  reset(force) {
    if (force || !this.input.value) {
      this.scope.reset();
    }
    this.el.reset();
    this.onInput();
    this.autoFocus();
  }

  onReady() {
    this.value = "";
    this.delay(this.onInput);
  }

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

  search(url) {
    if (url == null) {
      url = false;
    }
    this.addClass(this.constructor.activeClass);
    this.trigger("searching");

    this.hasResults = null;
    this.flags = { urlSearch: url, initialResults: true };
    this.searcher.find(this.scope.getScope().entries.all(), "text", this.value);
  }

  searchUrl() {
    let value;
    if (location.pathname === "/") {
      this.scope.searchUrl();
    } else if (!app.router.isIndex()) {
      return;
    }

    if (!(value = this.extractHashValue())) {
      return;
    }
    this.input.value = this.value = value;
    this.input.setSelectionRange(value.length, value.length);
    this.search(true);
    return true;
  }

  clear() {
    this.removeClass(this.constructor.activeClass);
    this.trigger("clear");
  }

  externalSearch(url) {
    let value;
    if ((value = this.value)) {
      if (this.scope.name()) {
        value = `${this.scope.name()} ${value}`;
      }
      $.popup(`${url}${encodeURIComponent(value)}`);
      this.reset();
    }
  }

  google() {
    this.externalSearch("https://www.google.com/search?q=");
  }

  stackoverflow() {
    this.externalSearch("https://stackoverflow.com/search?q=");
  }

  duckduckgo() {
    this.externalSearch("https://duckduckgo.com/?t=devdocs&q=");
  }

  onResults(results) {
    if (results.length) {
      this.hasResults = true;
    }
    this.trigger("results", results, this.flags);
    this.flags.initialResults = false;
  }

  onEnd() {
    if (!this.hasResults) {
      this.trigger("noresults");
    }
  }

  onClick(event) {
    if (event.target === this.resetLink) {
      $.stopEvent(event);
      this.reset();
    }
  }

  onSubmit(event) {
    $.stopEvent(event);
  }

  onScopeChange() {
    this.value = "";
    this.onInput();
  }

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

  extractHashValue() {
    const value = this.getHashValue();
    if (value != null) {
      app.router.replaceHash();
      return value;
    }
  }

  getHashValue() {
    try {
      return Search.HASH_RGX.exec($.urlDecode(location.hash))?.[1];
    } catch (error) {}
  }
};
