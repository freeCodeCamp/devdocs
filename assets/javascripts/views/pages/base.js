// @ts-check

/**
 * The base for the per-doc page views: docs whose pages need something done to
 * them once rendered.
 *
 * Syntax highlighting is spread over animation frames, so that a page with a
 * lot of code doesn't block scrolling while it is painted.
 */
app.views.BasePage = class BasePage extends app.View {
  /**
   * @param {HTMLElement} el
   * @param {Entry} entry
   */
  constructor(el, entry) {
    super(el);
    this.entry = entry;
  }

  /** Also drops the code blocks left to highlight. */
  deactivate() {
    if (super.deactivate()) {
      this.highlightNodes = [];
    }
  }

  /**
   * @param {string} content
   * @param {boolean} [fromCache]
   */
  render(content, fromCache) {
    if (fromCache == null) {
      fromCache = false;
    }
    this.highlightNodes = [];
    this.previousTiming = null;
    if (!this.statics().className) {
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

  /** Collects the code blocks and starts painting them. */
  highlightCode() {
    for (var el of this.findAll("pre[data-language]")) {
      var language = el.getAttribute("data-language");
      el.classList.add(`language-${language}`);
      this.highlightNodes.push(el);
    }
  }

  /**
   * Highlights as many code blocks as fit in the frame, then yields.
   *
   * @param {number} [timing] When the current frame started.
   */
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
      const clipEl = el.lastElementChild;
      if (clipEl) {
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
