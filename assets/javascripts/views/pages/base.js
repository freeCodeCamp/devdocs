app.views.BasePage = class BasePage extends app.View {
  constructor(el, entry) {
    super(el);
    this.entry = entry;
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      return (this.highlightNodes = []);
    }
  }

  render(content, fromCache) {
    if (fromCache == null) {
      fromCache = false;
    }
    this.highlightNodes = [];
    this.previousTiming = null;
    if (!this.constructor.className) {
      this.addClass(`_${this.entry.doc.type}`);
    }
    this.html(content);
    if (!fromCache) {
      this.highlightCode();
    }
    this.activate();
    if (this.afterRender) {
      this.delay(this.afterRender);
    }
    if (this.highlightNodes.length > 0) {
      requestAnimationFrame(() => this.paintCode());
    }
  }

  highlightCode() {
    for (var el of this.findAll("pre[data-language]")) {
      var language = el.getAttribute("data-language");
      el.classList.add(`language-${language}`);
      this.highlightNodes.push(el);
    }
  }

  paintCode(timing) {
    if (this.previousTiming) {
      if (Math.round(1000 / (timing - this.previousTiming)) > 50) {
        // fps
        this.nodesPerFrame = Math.round(
          Math.min(this.nodesPerFrame * 1.25, 50),
        );
      } else {
        this.nodesPerFrame = Math.round(Math.max(this.nodesPerFrame * 0.8, 10));
      }
    } else {
      this.nodesPerFrame = 10;
    }

    for (var el of this.highlightNodes.splice(0, this.nodesPerFrame)) {
      var clipEl;
      if ((clipEl = el.lastElementChild)) {
        $.remove(clipEl);
      }
      Prism.highlightElement(el);
      if (clipEl) {
        $.append(el, clipEl);
      }
    }

    if (this.highlightNodes.length > 0) {
      requestAnimationFrame(() => this.paintCode());
    }
    this.previousTiming = timing;
  }
};
