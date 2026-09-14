// @ts-check

/**
 * The pane holding whichever page is being shown.
 *
 * Owns one instance of each page view and swaps between them as the route
 * changes. Scroll positions are remembered per history entry and restored on
 * the way back, which is why the app turns the browser's own scroll
 * restoration off (see lib/page.js).
 */
class Content extends app.View {
  static el = "._content";
  static loadingClass = "_content-loading";

  static events = { click: "onClick" };

  static shortcuts = {
    altUp: "scrollStepUp",
    altDown: "scrollStepDown",
    pageUp: "scrollPageUp",
    pageDown: "scrollPageDown",
    pageTop: "scrollToTop",
    pageBottom: "scrollToBottom",
    altF: "onAltF",
  };

  static routes = {
    before: "beforeRoute",
    after: "afterRoute",
  };

  /** @inheritdoc */
  init() {
    this.scrollEl = app.isMobile()
      ? /** @type {HTMLElement} */ (document.scrollingElement) || document.body
      : this.el;
    this.scrollMap = {};
    this.scrollStack = [];

    this.rootPage = new app.views.RootPage();
    this.staticPage = new app.views.StaticPage();
    this.settingsPage = new app.views.SettingsPage();
    this.offlinePage = new app.views.OfflinePage();
    this.typePage = new app.views.TypePage();
    this.entryPage = new app.views.EntryPage();

    this.entryPage
      .on("loading", () => this.onEntryLoading())
      .on("loaded", () => this.onEntryLoaded());

    app
      .on("ready", () => this.onReady())
      .on("bootError", () => this.onBootError());
  }

  /** @param {View} view The page to show, replacing whatever is there. */
  show(view) {
    this.hideLoading();
    if (view !== this.view) {
      if (this.view != null) {
        this.view.deactivate();
      }
      this.html((this.view = view));
      this.view.activate();
    }
  }

  /** Marks the pane as waiting for a page. */
  showLoading() {
    this.addClass(this.statics().loadingClass);
  }

  /** @returns {boolean} */
  isLoading() {
    return this.el.classList.contains(this.statics().loadingClass);
  }

  /** Clears the loading state. */
  hideLoading() {
    this.removeClass(this.statics().loadingClass);
  }

  /** @param {number} [value] The offset to jump to. Defaults to the top. */
  scrollTo(value) {
    this.scrollEl.scrollTop = value || 0;
  }

  /** @param {number} value The offset to animate to. */
  smoothScrollTo(value) {
    if (app.settings.get("fastScroll")) {
      this.scrollTo(value);
    } else {
      $.smoothScroll(this.scrollEl, value || 0);
    }
  }

  /** @param {number} n How far to scroll, in pixels. */
  scrollBy(n) {
    this.smoothScrollTo(this.scrollEl.scrollTop + n);
  }

  /** Scrolls to the top of the page. */
  scrollToTop() {
    this.smoothScrollTo(0);
  }

  /** Scrolls to the bottom of the page. */
  scrollToBottom() {
    this.smoothScrollTo(this.scrollEl.scrollHeight);
  }

  /** Scrolls up by a small step. */
  scrollStepUp() {
    this.scrollBy(-80);
  }

  /** Scrolls down by a small step. */
  scrollStepDown() {
    this.scrollBy(80);
  }

  /** Scrolls up by most of a viewport. */
  scrollPageUp() {
    this.scrollBy(40 - this.scrollEl.clientHeight);
  }

  /** Scrolls down by most of a viewport. */
  scrollPageDown() {
    this.scrollBy(this.scrollEl.clientHeight - 40);
  }

  /** Brings the element named by the URL hash into view. */
  scrollToTarget() {
    let el;
    if (
      this.routeCtx.hash &&
      (el = this.findTargetByHash(this.routeCtx.hash))
    ) {
      $.scrollToWithImageLock(/** @type {HTMLElement} */ (el), this.scrollEl, "top", {
        margin: this.scrollEl === this.el ? 0 : $.offset(this.el).top,
      });
      $.openDetailsAncestors(el);
      $.highlight(el, { className: "_highlight" });
    } else {
      this.scrollTo(this.scrollMap[this.routeCtx.state.id]);
    }
  }

  /** Shows the first page once the docs have loaded. */
  onReady() {
    this.hideLoading();
  }

  /** Shows the boot error in place of a page. */
  onBootError() {
    this.hideLoading();
    this.html(this.tmpl("bootError"));
  }

  /** Marks the pane as waiting while an entry's page is fetched. */
  onEntryLoading() {
    this.showLoading();
    if (this.scrollToTargetTimeout) {
      clearTimeout(this.scrollToTargetTimeout);
      this.scrollToTargetTimeout = null;
    }
  }

  /** Clears the loading state once the entry has arrived. */
  onEntryLoaded() {
    this.hideLoading();
    if (this.scrollToTargetTimeout) {
      clearTimeout(this.scrollToTargetTimeout);
      this.scrollToTargetTimeout = null;
    }
    this.scrollToTarget();
  }

  /** @param {Context} context */
  beforeRoute(context) {
    this.cacheScrollPosition(context);

    /*
     * If scroll position wasn't cached from an earlier visit:
     * - let the anchor (if there is one) set position, or
     * - scroll to top.
     */
    if (!this.scrollMap[context.state.id] && !context.hash) {
      this.scrollToTop();
    }

    this.routeCtx = context;
    this.scrollToTargetTimeout = this.delay(this.scrollToTarget);
  }

  /**
   * Records where the page being left was scrolled to, against its history
   * entry, so that going back restores it.
   *
   * @param {Context} context
   */
  cacheScrollPosition(context) {
    if (!this.routeCtx || this.routeCtx.hash) {
      return;
    }
    if (this.routeCtx.path === "/") {
      return;
    }
    /*
     * Never cache a position for the state being entered. A single history
     * entry can be dispatched more than once, and by the second dispatch the
     * route context is already the one we're navigating to -- caching then
     * would overwrite the position saved for that state with the position of
     * the page currently on screen.
     */
    if (context?.state.id === this.routeCtx.state.id) {
      return;
    }

    if (this.scrollMap[this.routeCtx.state.id] == null) {
      this.scrollStack.push(this.routeCtx.state.id);
      while (this.scrollStack.length > app.config.history_cache_size) {
        delete this.scrollMap[this.scrollStack.shift()];
      }
    }

    this.scrollMap[this.routeCtx.state.id] = this.scrollEl.scrollTop;
  }

  /**
   * @param {string} route
   * @param {unknown} context
   */
  afterRoute(route, context) {
    if (route !== "entry" && route !== "type") {
      resetFavicon();
    }

    switch (route) {
      case "root":
        this.show(this.rootPage);
        break;
      case "entry":
        this.show(this.entryPage);
        break;
      case "type":
        this.show(this.typePage);
        break;
      case "settings":
        this.show(this.settingsPage);
        break;
      case "offline":
        this.show(this.offlinePage);
        break;
      default:
        this.show(this.staticPage);
    }

    this.view.onRoute(context);
    app.document.setTitle(
      typeof this.view.getTitle === "function"
        ? this.view.getTitle()
        : undefined,
    );
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const link = $.closestLink($.eventTarget(event), this.el);
    if (link && this.isExternalUrl(link.getAttribute("href"))) {
      $.stopEvent(event);
      $.popup(link);
    }
  }

  /**
   * Lets the browser's own find-in-page through.
   *
   * @param {ViewKeyboardEvent} event
   */
  onAltF(event) {
    if (
      !document.activeElement ||
      !$.hasChild(this.el, document.activeElement)
    ) {
      this.find("a:not(:empty)")?.focus();
      return $.stopEvent(event);
    }
  }

  /**
   * @param {string} hash Including the leading `#`.
   * @returns {unknown} The element the hash points at, or `undefined`.
   */
  findTargetByHash(hash) {
    let el = (() => {
      try {
        return $.id(decodeURIComponent(hash));
      } catch (error) {}
    })();
    if (!el) {
      el = (() => {
        try {
          return $.id(hash);
        } catch (error1) {}
      })();
    }
    return el;
  }

  /**
   * @param {string} url
   * @returns {boolean} Whether the URL leaves the app.
   */
  isExternalUrl(url) {
    return url?.startsWith("http:") || url?.startsWith("https:");
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Content = Content;
