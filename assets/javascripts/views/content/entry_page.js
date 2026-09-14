// @ts-check

/**
 * An entry's page.
 *
 * The HTML comes from the offline database when the doc is installed and from
 * the network otherwise. A few docs need their own handling once rendered,
 * which is what the sub-view classes in views/pages are for. Recently viewed
 * pages are kept in memory so that going back doesn't refetch them.
 */
class EntryPage extends app.View {
  static className = "_page";
  static errorClass = "_page-error";

  static events = { click: "onClick" };

  static shortcuts = {
    altC: "onAltC",
    altO: "onAltO",
  };

  static routes = { before: "beforeRoute" };

  static LINKS = {
    home: "Homepage",
    code: "Source code",
  };

  /** @inheritdoc */
  init() {
    this.cacheMap = {};
    this.cacheStack = [];
  }

  /** Also abandons any page still loading. */
  deactivate() {
    if (super.deactivate()) {
      this.hideTransientNotice();
      this.empty();
      this.entry = null;
    }
  }

  /** Announces that a page is on its way. */
  loading() {
    this.empty();
    this.trigger("loading");
  }

  /**
   * @param {string} content The entry's HTML.
   * @param {boolean} [fromCache] Whether it came from the in-memory cache,
   *   in which case it has already been prepared.
   */
  render(content, fromCache) {
    if (content == null) {
      content = "";
    }
    if (fromCache == null) {
      fromCache = false;
    }
    if (!this.activated) {
      return;
    }
    this.empty();
    this.subview = new (this.subViewClass())(this.el, this.entry);

    $.batchUpdate(this.el, () => {
      this.subview.render(content, fromCache);
      if (!fromCache) {
        this.addCopyButtons();
      }
    });

    if (app.disabledDocs.findBy("slug", this.entry.doc.slug)) {
      this.hiddenView = new app.views.HiddenPage(this.el, this.entry);
    }

    setFaviconForDoc(this.entry.doc);
    this.delay(this.polyfillMathML);
    this.trigger("loaded");
  }

  /** Adds a copy button to each code block. */
  addCopyButtons() {
    if (!this.copyButton) {
      this.copyButton = document.createElement("button");
      this.copyButton.innerHTML = '<svg><use xlink:href="#icon-copy"/></svg>';
      this.copyButton.type = "button";
      this.copyButton.className = "_pre-clip";
      this.copyButton.title = "Copy to clipboard";
      this.copyButton.setAttribute("aria-label", "Copy to clipboard");
    }
    for (var el of this.findAllByTag("pre")) {
      el.appendChild(this.copyButton.cloneNode(true));
    }
  }

  /** Loads the MathML stylesheet, for browsers that don't render it natively. */
  polyfillMathML() {
    if (
      window.supportsMathML !== false ||
      !!this.polyfilledMathML ||
      !this.findByTag("math")
    ) {
      return;
    }
    this.polyfilledMathML = true;
    $.append(
      document.head,
      `<link rel="stylesheet" href="${app.config.mathml_stylesheet}">`,
    );
  }

  /**
   * @param {string} content
   * @returns {string} The HTML with the doc's own fixes applied.
   */
  prepareContent(content) {
    if (!this.entry.isIndex() || !this.entry.doc.links) {
      return content;
    }

    const links = Object.entries(this.entry.doc.links).map(([link, url]) => {
      return `<a href="${url}" class="_links-link">${EntryPage.LINKS[link]}</a>`;
    });

    return `<p class="_links">${links.join("")}</p>${content}`;
  }

  /** Also tears down the doc's sub-view. */
  empty() {
    if (this.subview != null) {
      this.subview.deactivate();
    }
    this.subview = null;

    if (this.hiddenView != null) {
      this.hiddenView.deactivate();
    }
    this.hiddenView = null;

    this.resetClass();
    super.empty();
  }

  /** @returns {any} The views/pages class this doc needs, if it has one. */
  subViewClass() {
    // doc.type is optional (e.g. the Q documentation has none).
    const type = this.entry.doc.type;
    return (type && app.views[`${$.classify(type)}Page`]) || app.views.BasePage;
  }

  /** @returns {string} */
  getTitle() {
    return (
      this.entry.doc.fullName +
      (this.entry.isIndex() ? " documentation" : ` / ${this.entry.name}`)
    );
  }

  /** Abandons a page still in flight when the route changes. */
  beforeRoute() {
    this.cache();
    this.abort();
  }

  /** @param {Context} context */
  onRoute(context) {
    const isSameFile = context.entry.filePath() === this.entry?.filePath?.();
    this.entry = context.entry;
    if (!isSameFile) {
      this.restore() || this.load();
    }
  }

  /** Fetches the entry's page, from the offline database or the network. */
  load() {
    this.loading();
    this.xhr = this.entry.loadFile(
      (response) => this.onSuccess(response),
      () => this.onError(),
    );
  }

  /** Cancels the request in flight, if any. */
  abort() {
    if (this.xhr) {
      this.xhr.abort();
      this.xhr = this.entry = null;
    }
  }

  /** @param {string} response The entry's HTML. */
  onSuccess(response) {
    if (!this.activated) {
      return;
    }
    this.xhr = null;
    this.render(this.prepareContent(response));
  }

  /** Shows the load error in place of the page. */
  onError() {
    this.xhr = null;
    this.render(this.tmpl("pageLoadError"));
    this.resetClass();
    this.addClass(this.statics().errorClass);
    if (app.serviceWorker != null) {
      app.serviceWorker.update();
    }
  }

  /** Keeps the rendered page in memory, evicting the oldest. */
  cache() {
    let path;
    if (
      this.xhr ||
      !this.entry ||
      this.cacheMap[(path = this.entry.filePath())]
    ) {
      return;
    }

    this.cacheMap[path] = this.el.innerHTML;
    this.cacheStack.push(path);

    while (this.cacheStack.length > app.config.history_cache_size) {
      delete this.cacheMap[this.cacheStack.shift()];
    }
  }

  /** @returns {boolean | undefined} `true` when the page came from memory. */
  restore() {
    const path = this.entry.filePath();
    if (this.cacheMap[[path]]) {
      this.render(this.cacheMap[path], true);
      return true;
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    const target = $.eventTarget(event);
    if (target.hasAttribute("data-retry")) {
      $.stopEvent(event);
      this.load();
    } else if (target.classList.contains("_pre-clip")) {
      $.stopEvent(event);
      navigator.clipboard.writeText(target.parentNode.textContent).then(
        () => target.classList.add("_pre-clip-success"),
        () => target.classList.add("_pre-clip-error"),
      );
      setTimeout(() => (target.className = "_pre-clip"), 2000);
    }
  }

  /** @returns {any} The link to the entry on the documentation's own site. */
  originalLink() {
    // The attribution is appended last but may be followed by other elements,
    // so match on the last attribution rather than on its sibling position.
    const links = this.findAll("._attribution ._attribution-link");
    return links[links.length - 1];
  }

  /** Copies the original page's link. */
  onAltC() {
    const link = this.originalLink();
    if (!link) {
      this.showTransientNotice("noOriginalLink");
      return;
    }
    if (!navigator.clipboard) {
      this.showTransientNotice("copyFailed");
      return;
    }
    navigator.clipboard.writeText(link.href + location.hash).catch(() => {
      // The rejection may arrive after the user navigated away. This view is
      // reused across entries, so only report the failure while the page that
      // was copied from is still the one on screen.
      if (this.activated && link.isConnected) {
        this.showTransientNotice("copyFailed");
      }
    });
  }

  /** Opens the original page. */
  onAltO() {
    const link = this.originalLink();
    if (!link) {
      this.showTransientNotice("noOriginalLink");
      return;
    }
    this.delay(() => $.popup(link.href + location.hash));
  }

  /** @param {string} type Names the notice template to show. */
  showTransientNotice(type) {
    this.hideTransientNotice();
    this.transientNotice = new app.views.Notice(type);
    // Persistent notices (single doc, disabled doc) share the same bounds and
    // z-index, so raise this one to keep it visible while it's shown.
    this.transientNotice.addClass("_notice-transient");
    this.transientNoticeTimer = this.delay(this.hideTransientNotice, 3000);
  }

  /** Takes the notice back off. */
  hideTransientNotice() {
    if (!this.transientNotice) {
      return;
    }
    clearTimeout(this.transientNoticeTimer);
    this.transientNotice.deactivate();
    this.transientNotice = null;
    this.transientNoticeTimer = null;
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.EntryPage = EntryPage;
