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
app.views.Sidebar = class Sidebar extends app.View {
  static initClass() {
    this.el = "._sidebar";

    this.events = {
      focus: "onFocus",
      select: "onSelect",
      click: "onClick",
    };

    this.routes = { after: "afterRoute" };

    this.shortcuts = {
      altR: "onAltR",
      escape: "onEscape",
    };
  }

  init() {
    if (!app.isMobile()) {
      this.addSubview((this.hover = new app.views.SidebarHover(this.el)));
    }
    this.addSubview((this.search = new app.views.Search()));

    this.search
      .on("searching", () => this.onSearching())
      .on("clear", () => this.onSearchClear())
      .scope.on("change", (newDoc, previousDoc) =>
        this.onScopeChange((newDoc, previousDoc)),
      );

    this.results = new app.views.Results(this, this.search);
    this.docList = new app.views.DocList();

    app.on("ready", () => this.onReady());

    $.on(document.documentElement, "mouseleave", () => this.hide());
    $.on(document.documentElement, "mouseenter", () =>
      this.resetDisplay({ forceNoHover: false }),
    );
  }

  hide() {
    this.removeClass("show");
  }

  display() {
    this.addClass("show");
  }

  resetDisplay(options) {
    if (options == null) {
      options = {};
    }
    if (!this.hasClass("show")) {
      return;
    }
    this.removeClass("show");

    if (options.forceNoHover !== false && !this.hasClass("no-hover")) {
      this.addClass("no-hover");
      this.resetHoverOnMouseMove = this.resetHoverOnMouseMove.bind(this);
      $.on(window, "mousemove", this.resetHoverOnMouseMove);
    }
  }

  resetHoverOnMouseMove() {
    $.off(window, "mousemove", this.resetHoverOnMouseMove);
    return $.requestAnimationFrame(() => this.resetHover());
  }

  resetHover() {
    return this.removeClass("no-hover");
  }

  showView(view) {
    if (this.view !== view) {
      if (this.hover != null) {
        this.hover.hide();
      }
      this.saveScrollPosition();
      if (this.view != null) {
        this.view.deactivate();
      }
      this.view = view;
      this.render();
      this.view.activate();
      this.restoreScrollPosition();
    }
  }

  render() {
    this.html(this.view);
  }

  showDocList() {
    this.showView(this.docList);
  }

  showResults() {
    this.display();
    this.showView(this.results);
  }

  reset() {
    this.display();
    this.showDocList();
    this.docList.reset();
    this.search.reset();
  }

  onReady() {
    this.view = this.docList;
    this.render();
    this.view.activate();
  }

  onScopeChange(newDoc, previousDoc) {
    if (previousDoc) {
      this.docList.closeDoc(previousDoc);
    }
    if (newDoc) {
      this.docList.reveal(newDoc.toEntry());
    } else {
      this.scrollToTop();
    }
  }

  saveScrollPosition() {
    if (this.view === this.docList) {
      this.scrollTop = this.el.scrollTop;
    }
  }

  restoreScrollPosition() {
    if (this.view === this.docList && this.scrollTop) {
      this.el.scrollTop = this.scrollTop;
      this.scrollTop = null;
    } else {
      this.scrollToTop();
    }
  }

  scrollToTop() {
    this.el.scrollTop = 0;
  }

  onSearching() {
    this.showResults();
  }

  onSearchClear() {
    this.resetDisplay();
    this.showDocList();
  }

  onFocus(event) {
    this.display();
    if (event.target !== this.el) {
      $.scrollTo(event.target, this.el, "continuous", { bottomGap: 2 });
    }
  }

  onSelect() {
    this.resetDisplay();
  }

  onClick(event) {
    if (event.which !== 1) {
      return;
    }
    if (
      __guardMethod__($.eventTarget(event), "hasAttribute", (o) =>
        o.hasAttribute("data-reset-list"),
      )
    ) {
      $.stopEvent(event);
      this.onAltR();
    }
  }

  onAltR() {
    this.reset();
    this.docList.reset({ revealCurrent: true });
    this.display();
  }

  onEscape() {
    let doc;
    this.reset();
    this.resetDisplay();
    if ((doc = this.search.getScopeDoc())) {
      this.docList.reveal(doc.toEntry());
    } else {
      this.scrollToTop();
    }
  }

  onDocEnabled() {
    this.docList.onEnabled();
    this.reset();
  }

  afterRoute(name, context) {
    if (
      (app.shortcuts.eventInProgress != null
        ? app.shortcuts.eventInProgress.name
        : undefined) === "escape"
    ) {
      return;
    }
    if (!context.init && app.router.isIndex()) {
      this.reset();
    }
    this.resetDisplay();
  }
};
app.views.Sidebar.initClass();

function __guardMethod__(obj, methodName, transform) {
  if (
    typeof obj !== "undefined" &&
    obj !== null &&
    typeof obj[methodName] === "function"
  ) {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
