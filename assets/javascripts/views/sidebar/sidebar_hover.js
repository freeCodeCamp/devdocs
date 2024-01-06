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
app.views.SidebarHover = class SidebarHover extends app.View {
  static initClass() {
    this.itemClass = "_list-hover";

    this.events = {
      focus: "onFocus",
      blur: "onBlur",
      mouseover: "onMouseover",
      mouseout: "onMouseout",
      scroll: "onScroll",
      click: "onClick",
    };

    this.routes = { after: "onRoute" };
  }

  constructor(el) {
    super(...arguments);
    this.el = el;
    if (!isPointerEventsSupported()) {
      delete this.constructor.events.mouseover;
    }
  }

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
    return __guard__(el != null ? el.classList : undefined, (x) =>
      x.contains(this.constructor.itemClass),
    );
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
app.views.SidebarHover.initClass();

var isPointerEventsSupported = function () {
  const el = document.createElement("div");
  el.style.cssText = "pointer-events: auto";
  return el.style.pointerEvents === "auto";
};

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}
