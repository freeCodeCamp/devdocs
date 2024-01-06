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

  hide() {
    if (this.cursor) {
      $.remove(this.clone);
      this.cursor = this.clone = null;
    }
  }

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

  makeClone(el) {
    const clone = el.cloneNode(true);
    clone.classList.add("clone");
    return clone;
  }

  isTarget(el) {
    return el.classList?.contains(this.constructor.itemClass);
  }

  isSelected(el) {
    return el.classList.contains("active");
  }

  isTruncated(el) {
    return el.scrollWidth > el.offsetWidth;
  }

  onFocus(event) {
    this.focusTime = Date.now();
    this.show(event.target);
  }

  onBlur() {
    this.hide();
  }

  onMouseover(event) {
    if (
      this.isTarget(event.target) &&
      !this.isSelected(event.target) &&
      this.mouseActivated()
    ) {
      this.show(event.target);
    }
  }

  onMouseout(event) {
    if (this.isTarget(event.target) && this.mouseActivated()) {
      this.hide();
    }
  }

  mouseActivated() {
    // Skip mouse events caused by focus events scrolling the sidebar.
    return !this.focusTime || Date.now() - this.focusTime > 500;
  }

  onScroll() {
    this.position();
  }

  onClick(event) {
    if (event.target === this.clone) {
      $.click(this.cursor);
    }
  }

  onRoute() {
    this.hide();
  }
};
