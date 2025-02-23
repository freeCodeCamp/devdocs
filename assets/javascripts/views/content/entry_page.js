app.views.EntryPage = class EntryPage extends app.View {
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

  init() {
    this.cacheMap = {};
    this.cacheStack = [];
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
      this.entry = null;
    }
  }

  loading() {
    this.empty();
    this.trigger("loading");
  }

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

  prepareContent(content) {
    if (!this.entry.isIndex() || !this.entry.doc.links) {
      return content;
    }

    const links = Object.entries(this.entry.doc.links).map(([link, url]) => {
      return `<a href="${url}" class="_links-link">${EntryPage.LINKS[link]}</a>`;
    });

    return `<p class="_links">${links.join("")}</p>${content}`;
  }

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
    super.empty(...arguments);
  }

  subViewClass() {
    return (
      app.views[`${$.classify(this.entry.doc.type)}Page`] || app.views.BasePage
    );
  }

  getTitle() {
    return (
      this.entry.doc.fullName +
      (this.entry.isIndex() ? " documentation" : ` / ${this.entry.name}`)
    );
  }

  beforeRoute() {
    this.cache();
    this.abort();
  }

  onRoute(context) {
    const isSameFile = context.entry.filePath() === this.entry?.filePath?.();
    this.entry = context.entry;
    if (!isSameFile) {
      this.restore() || this.load();
    }
  }

  load() {
    this.loading();
    this.xhr = this.entry.loadFile(
      (response) => this.onSuccess(response),
      () => this.onError(),
    );
  }

  abort() {
    if (this.xhr) {
      this.xhr.abort();
      this.xhr = this.entry = null;
    }
  }

  onSuccess(response) {
    if (!this.activated) {
      return;
    }
    this.xhr = null;
    this.render(this.prepareContent(response));
  }

  onError() {
    this.xhr = null;
    this.render(this.tmpl("pageLoadError"));
    this.resetClass();
    this.addClass(this.constructor.errorClass);
    if (app.serviceWorker != null) {
      app.serviceWorker.update();
    }
  }

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

  restore() {
    const path = this.entry.filePath();
    if (this.cacheMap[[path]]) {
      this.render(this.cacheMap[path], true);
      return true;
    }
  }

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

  onAltC() {
    const link = this.find("._attribution:last-child ._attribution-link");
    if (!link) {
      return;
    }
    console.log(link.href + location.hash);
    navigator.clipboard.writeText(link.href + location.hash);
  }

  onAltO() {
    const link = this.find("._attribution:last-child ._attribution-link");
    if (!link) {
      return;
    }
    this.delay(() => $.popup(link.href + location.hash));
  }
};
