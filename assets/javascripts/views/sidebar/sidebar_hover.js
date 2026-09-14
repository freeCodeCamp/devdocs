// @ts-check

/**
 * The tooltip shown over a sidebar row whose label is too long to fit.
 *
 * Rather than styling the row itself, a copy of it is positioned over the
 * original outside the sidebar's overflow, so that it can spill past the edge.
 */
app.views.SidebarHover = class SidebarHover extends app.View {
  static itemClass = "_list-hover";

  static events = {
    focus: "onFocus",
    blur: "onBlur",
    mouseover: "onMouseover",
    mouseout: "onMouseout",
    scroll: "onScroll",
    click: "onClick",
  };

  static routes = { after: "onRoute" };

  /** @param {any} el The row to show in full, if it is truncated. */
  show(el) {
    if (el !== this.cursor) {
      this.hide();
      if (this.isTarget(el) && this.isTruncated(el.lastElementChild || el)) {
        this.cursor = el;
        this.clone = this.makeClone(this.cursor);
        $.append(document.body, this.clone);
        if (this.offsetTop == null) {
          this.offsetTop = this.el.offsetTop;
        }
        this.position();
      }
    }
  }

  /** Takes the copy off the page. */
  hide() {
    if (this.cursor) {
      $.remove(this.clone);
      this.cursor = this.clone = null;
    }
  }

  /** Lines the copy up with the row, hiding it once the row scrolls out of view. */
  position() {
    if (this.cursor) {
      const rect = $.rect(this.cursor);
      if (rect.top >= this.offsetTop) {
        this.clone.style.top = rect.top + "px";
        this.clone.style.left = rect.left + "px";
      } else {
        this.hide();
      }
    }
  }

  /**
   * @param {any} el
   * @returns {unknown} A copy of the row, positioned over the original.
   */
  makeClone(el) {
    const clone = el.cloneNode(true);
    clone.classList.add("clone");
    return clone;
  }

  /**
   * @param {any} el
   * @returns {boolean} Whether the row is one that can be hovered.
   */
  isTarget(el) {
    return el.classList?.contains(this.statics().itemClass);
  }

  /**
   * @param {any} el
   * @returns {boolean}
   */
  isSelected(el) {
    return el.classList.contains("active");
  }

  /**
   * @param {any} el
   * @returns {boolean} Whether the label is clipped by its row.
   */
  isTruncated(el) {
    return el.scrollWidth > el.offsetWidth;
  }

  /** @param {ViewEvent} event */
  onFocus(event) {
    this.focusTime = Date.now();
    this.show(event.target);
  }

  /** Hides the tooltip. */
  onBlur() {
    this.hide();
  }

  /** @param {ViewMouseEvent} event */
  onMouseover(event) {
    if (
      this.isTarget(event.target) &&
      !this.isSelected(event.target) &&
      this.mouseActivated()
    ) {
      this.show(event.target);
    }
  }

  /** @param {ViewMouseEvent} event */
  onMouseout(event) {
    if (this.isTarget(event.target) && this.mouseActivated()) {
      this.hide();
    }
  }

  /** @returns {boolean} Whether the pointer, rather than the keyboard, is driving. */
  mouseActivated() {
    // Skip mouse events caused by focus events scrolling the sidebar.
    return !this.focusTime || Date.now() - this.focusTime > 500;
  }

  /** Keeps the copy lined up as the sidebar scrolls. */
  onScroll() {
    this.position();
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.target === this.clone) {
      $.click(this.cursor);
    }
  }

  /** Hides the tooltip on navigation. */
  onRoute() {
    this.hide();
  }
};
