// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function () {
  let SEARCH_PARAM = undefined;
  let HASH_RGX = undefined;
  app.views.SearchScope = class SearchScope extends app.View {
    static initClass() {
      SEARCH_PARAM = app.config.search_param;

      this.elements = {
        input: "._search-input",
        tag: "._search-tag",
      };

      this.events = {
        click: "onClick",
        keydown: "onKeydown",
        textInput: "onTextInput",
      };

      this.routes = { after: "afterRoute" };

      HASH_RGX = new RegExp(`^#${SEARCH_PARAM}=(.+?) .`);
    }

    constructor(el) {
      super(...arguments);
      this.el = el;
    }

    init() {
      this.placeholder = this.input.getAttribute("placeholder");

      this.searcher = new app.SynchronousSearcher({
        fuzzy_min_length: 2,
        max_results: 1,
      });
      this.searcher.on("results", (results) => this.onResults(results));
    }

    getScope() {
      return this.doc || app;
    }

    isActive() {
      return !!this.doc;
    }

    name() {
      return this.doc != null ? this.doc.name : undefined;
    }

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

    searchUrl() {
      let value;
      if ((value = this.extractHashValue())) {
        this.search(value, true);
      }
    }

    onResults(results) {
      let doc;
      if (!(doc = results[0])) {
        return;
      }
      if (app.docs.contains(doc)) {
        this.selectDoc(doc);
      } else {
        this.redirectToDoc(doc);
      }
    }

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

    redirectToDoc(doc) {
      const { hash } = location;
      app.router.replaceHash("");
      location.assign(doc.fullPath() + hash);
    }

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

    doScopeSearch(event) {
      this.search(this.input.value.slice(0, this.input.selectionStart));
      if (this.doc) {
        $.stopEvent(event);
      }
    }

    onClick(event) {
      if (event.target === this.tag) {
        this.reset();
        $.stopEvent(event);
      }
    }

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

    onTextInput(event) {
      if (!$.isChromeForAndroid()) {
        return;
      }
      if (!this.doc && this.input.value && event.data === " ") {
        this.doScopeSearch(event);
      }
    }

    extractHashValue() {
      let value;
      if ((value = this.getHashValue())) {
        const newHash = $.urlDecode(location.hash).replace(
          `#${SEARCH_PARAM}=${value} `,
          `#${SEARCH_PARAM}=`,
        );
        app.router.replaceHash(newHash);
        return value;
      }
    }

    getHashValue() {
      try {
        return __guard__(
          HASH_RGX.exec($.urlDecode(location.hash)),
          (x) => x[1],
        );
      } catch (error) {}
    }

    afterRoute(name, context) {
      if (!app.isSingleDoc() && context.init && context.doc) {
        this.selectDoc(context.doc);
      }
    }
  };
  app.views.SearchScope.initClass();
  return app.views.SearchScope;
})();

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}
