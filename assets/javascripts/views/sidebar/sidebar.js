// @ts-check

/**
 * The sidebar: the search field, and below it either the doc list or the
 * search results.
 *
 * Swapping between the two keeps the doc list's scroll position, so that
 * clearing a search puts the user back where they were.
 */
class Sidebar extends app.View {
  static el = "._sidebar";

  static events = {
    focus: "onFocus",
    select: "onSelect",
    click: "onClick",
  };

  static routes = { after: "afterRoute" };

  static shortcuts = {
    altR: "onAltR",
    escape: "onEscape",
  };

  /** @inheritdoc */
  init() {
    if (!app.isMobile()) {
      this.addSubview((this.hover = new app.views.SidebarHover(this.el)));
    }
    this.addSubview((this.search = new app.views.Search()));

    this.search
      .on("searching", () => this.onSearching())
      .on("clear", () => this.onSearchClear())
      .scope.on("change", (newDoc, previousDoc) =>
        this.onScopeChange(newDoc, previousDoc),
      );

    this.results = new app.views.Results(this, this.search);
    this.docList = new app.views.DocList();

    app.on("ready", () => this.onReady());

    $.on(document.documentElement, "mouseleave", () => this.hide());
    $.on(document.documentElement, "mouseenter", () =>
      this.resetDisplay({ forceNoHover: false }),
    );
  }

  /** Slides the sidebar away, on the layouts where it overlays the content. */
  hide() {
    this.removeClass("show");
  }

  /** Slides the sidebar back in. */
  display() {
    this.addClass("show");
  }

  /**
   * @param {{ forceNoHover?: boolean }} [options] Pass `forceNoHover: false`
   *   to let the sidebar reopen on hover again.
   */
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

  /** Re-enables hover once the pointer moves again. */
  resetHoverOnMouseMove() {
    $.off(window, "mousemove", this.resetHoverOnMouseMove);
    return requestAnimationFrame(() => this.resetHover());
  }

  /** Re-enables opening the sidebar on hover. */
  resetHover() {
    return this.removeClass("no-hover");
  }

  /** @param {unknown} view The view to show below the search field. */
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

  /** Shows whichever of the doc list and the results belongs on screen. */
  render() {
    this.html(this.view);
  }

  /** Swaps the doc list in, restoring where it was scrolled to. */
  showDocList() {
    this.showView(this.docList);
  }

  /** Swaps the results in, remembering where the doc list was scrolled to. */
  showResults() {
    this.display();
    this.showView(this.results);
  }

  /** Clears the search and returns the doc list to the entry being read. */
  reset() {
    this.display();
    this.showDocList();
    this.docList.reset();
    this.search.reset();
  }

  /** Renders once the docs have loaded. */
  onReady() {
    this.view = this.docList;
    this.render();
    this.view.activate();
  }

  /**
   * @param {Doc} [newDoc] The doc the search is now scoped to.
   * @param {Doc} [previousDoc] The doc it was scoped to before.
   */
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

  /** Remembers where the doc list is scrolled to. */
  saveScrollPosition() {
    if (this.view === this.docList) {
      this.scrollTop = this.el.scrollTop;
    }
  }

  /** Puts the doc list back where it was. */
  restoreScrollPosition() {
    if (this.view === this.docList && this.scrollTop) {
      this.el.scrollTop = this.scrollTop;
      this.scrollTop = null;
    } else {
      this.scrollToTop();
    }
  }

  /** Scrolls the sidebar to the top. */
  scrollToTop() {
    this.el.scrollTop = 0;
  }

  /** Swaps in the results. */
  onSearching() {
    this.showResults();
  }

  /** Swaps the doc list back in. */
  onSearchClear() {
    this.resetDisplay();
    this.showDocList();
  }

  /** @param {ViewEvent} event */
  onFocus(event) {
    this.display();
    if (event.target !== this.el) {
      $.scrollTo(event.target, this.el, "continuous", { bottomGap: 2 });
    }
  }

  /** Keeps the selected row in view. */
  onSelect() {
    this.resetDisplay();
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.which !== 1) {
      return;
    }
    if ($.eventTarget(event).hasAttribute?.("data-reset-list")) {
      $.stopEvent(event);
      this.onAltR();
    }
  }

  /** Returns the doc list to the entry being read. */
  onAltR() {
    this.reset();
    this.docList.reset({ revealCurrent: true });
    this.display();
  }

  /** Clears the search. */
  onEscape() {
    const doc = this.search.getScopeDoc();
    this.reset();
    this.resetDisplay();
    if (doc) {
      this.docList.reveal(doc.toEntry());
    } else {
      this.scrollToTop();
    }
  }

  /** Rebuilds after a doc was enabled from a result. */
  onDocEnabled() {
    this.docList.onEnabled();
    this.reset();
  }

  /**
   * @param {string} name
   * @param {any} context
   */
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
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.Sidebar = Sidebar;
