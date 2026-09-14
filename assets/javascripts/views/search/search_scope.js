// @ts-check

/**
 * Narrowing the search to one doc.
 *
 * Typing a doc's name and then space or tab turns what was typed into a tag in
 * front of the field, and the rest of the query is then matched within that
 * doc alone. The scope can also come from the URL hash, or from arriving on a
 * doc's page.
 *
 * Emits `change` with the new doc and the previous one.
 */
class SearchScope extends app.View {
  static SEARCH_PARAM = app.config.search_param;

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

    this.searcher = new app.SynchronousSearcher({
      fuzzy_min_length: 2,
      max_results: 1,
    });
    this.searcher.on("results", (results) => this.onResults(results));
  }

  /** @returns {Doc | App} The doc the search is scoped to, or the app when it isn't scoped. */
  getScope() {
    return this.doc || app;
  }

  /** @returns {boolean} Whether the search is scoped to a doc. */
  isActive() {
    return !!this.doc;
  }

  /** @returns {string | undefined} The scoped doc's name. */
  name() {
    return this.doc?.name;
  }

  /**
   * Scopes to the doc `value` names, if it names one.
   *
   * @param {string} value
   * @param {boolean} [searchDisabled] Also match docs that aren't enabled,
   *   which then redirect rather than scope.
   */
  search(value, searchDisabled) {
    if (searchDisabled == null) {
      searchDisabled = false;
    }
    if (this.doc) {
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

    this.tag.textContent = doc.fullName;
    this.tag.style.display = "block";

    this.input.removeAttribute("placeholder");
    this.input.value = this.input.value.slice(this.input.selectionStart);
    this.input.style.paddingLeft = this.tag.offsetWidth + 10 + "px";

    $.trigger(this.input, "input");
    this.trigger("change", this.doc, previousDoc);
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
    if (!this.doc) {
      return;
    }
    const previousDoc = this.doc;
    this.doc = null;

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
    if (this.doc) {
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
    if (event.which === 8) {
      // backspace
      if (this.doc && this.input.selectionEnd === 0) {
        this.reset();
        $.stopEvent(event);
      }
    } else if (!this.doc && this.input.value && !$.isChromeForAndroid()) {
      if (event.ctrlKey || event.metaKey || event.altKey || event.shiftKey) {
        return;
      }
      if (
        event.which === 9 || // tab
        (event.which === 32 && app.isMobile())
      ) {
        // space
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
    if (!this.doc && this.input.value && event.data === " ") {
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

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.SearchScope = SearchScope;
