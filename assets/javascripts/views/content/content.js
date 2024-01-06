// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.Content = class Content extends app.View {
  constructor(...args) {
    this.scrollToTop = this.scrollToTop.bind(this);
    this.scrollToBottom = this.scrollToBottom.bind(this);
    this.scrollStepUp = this.scrollStepUp.bind(this);
    this.scrollStepDown = this.scrollStepDown.bind(this);
    this.scrollPageUp = this.scrollPageUp.bind(this);
    this.scrollPageDown = this.scrollPageDown.bind(this);
    this.onReady = this.onReady.bind(this);
    this.onBootError = this.onBootError.bind(this);
    this.onEntryLoading = this.onEntryLoading.bind(this);
    this.onEntryLoaded = this.onEntryLoaded.bind(this);
    this.beforeRoute = this.beforeRoute.bind(this);
    this.afterRoute = this.afterRoute.bind(this);
    this.onClick = this.onClick.bind(this);
    this.onAltF = this.onAltF.bind(this);
    super(...args);
  }

  static initClass() {
    this.el = "._content";
    this.loadingClass = "_content-loading";

    this.events = { click: "onClick" };

    this.shortcuts = {
      altUp: "scrollStepUp",
      altDown: "scrollStepDown",
      pageUp: "scrollPageUp",
      pageDown: "scrollPageDown",
      pageTop: "scrollToTop",
      pageBottom: "scrollToBottom",
      altF: "onAltF",
    };

    this.routes = {
      before: "beforeRoute",
      after: "afterRoute",
    };
  }

  init() {
    this.scrollEl = app.isMobile()
      ? document.scrollingElement || document.body
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
      .on("loading", this.onEntryLoading)
      .on("loaded", this.onEntryLoaded);

    app.on("ready", this.onReady).on("bootError", this.onBootError);
  }

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

  showLoading() {
    this.addClass(this.constructor.loadingClass);
  }

  isLoading() {
    return this.el.classList.contains(this.constructor.loadingClass);
  }

  hideLoading() {
    this.removeClass(this.constructor.loadingClass);
  }

  scrollTo(value) {
    this.scrollEl.scrollTop = value || 0;
  }

  smoothScrollTo(value) {
    if (app.settings.get("fastScroll")) {
      this.scrollTo(value);
    } else {
      $.smoothScroll(this.scrollEl, value || 0);
    }
  }

  scrollBy(n) {
    this.smoothScrollTo(this.scrollEl.scrollTop + n);
  }

  scrollToTop() {
    this.smoothScrollTo(0);
  }

  scrollToBottom() {
    this.smoothScrollTo(this.scrollEl.scrollHeight);
  }

  scrollStepUp() {
    this.scrollBy(-80);
  }

  scrollStepDown() {
    this.scrollBy(80);
  }

  scrollPageUp() {
    this.scrollBy(40 - this.scrollEl.clientHeight);
  }

  scrollPageDown() {
    this.scrollBy(this.scrollEl.clientHeight - 40);
  }

  scrollToTarget() {
    let el;
    if (
      this.routeCtx.hash &&
      (el = this.findTargetByHash(this.routeCtx.hash))
    ) {
      $.scrollToWithImageLock(el, this.scrollEl, "top", {
        margin: this.scrollEl === this.el ? 0 : $.offset(this.el).top,
      });
      $.highlight(el, { className: "_highlight" });
    } else {
      this.scrollTo(this.scrollMap[this.routeCtx.state.id]);
    }
  }

  onReady() {
    this.hideLoading();
  }

  onBootError() {
    this.hideLoading();
    this.html(this.tmpl("bootError"));
  }

  onEntryLoading() {
    this.showLoading();
    if (this.scrollToTargetTimeout) {
      clearTimeout(this.scrollToTargetTimeout);
      this.scrollToTargetTimeout = null;
    }
  }

  onEntryLoaded() {
    this.hideLoading();
    if (this.scrollToTargetTimeout) {
      clearTimeout(this.scrollToTargetTimeout);
      this.scrollToTargetTimeout = null;
    }
    this.scrollToTarget();
  }

  beforeRoute(context) {
    this.cacheScrollPosition();
    this.routeCtx = context;
    this.scrollToTargetTimeout = this.delay(this.scrollToTarget);
  }

  cacheScrollPosition() {
    if (!this.routeCtx || this.routeCtx.hash) {
      return;
    }
    if (this.routeCtx.path === "/") {
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

  onClick(event) {
    const link = $.closestLink($.eventTarget(event), this.el);
    if (link && this.isExternalUrl(link.getAttribute("href"))) {
      $.stopEvent(event);
      $.popup(link);
    }
  }

  onAltF(event) {
    if (
      !document.activeElement ||
      !$.hasChild(this.el, document.activeElement)
    ) {
      __guard__(this.find("a:not(:empty)"), (x) => x.focus());
      return $.stopEvent(event);
    }
  }

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

  isExternalUrl(url) {
    let needle;
    return (
      (needle = __guard__(url, (x) => x.slice(0, 6))),
      ["http:/", "https:"].includes(needle)
    );
  }
};
app.views.Content.initClass();

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}
