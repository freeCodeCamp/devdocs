// @ts-check

/**
 * Expanding and collapsing the sidebar's nested lists.
 *
 * Attached alongside a list rather than owning it: rows carrying
 * `targetClass` can be folded, the arrow carrying `handleClass` toggles them,
 * and an expanded row carries `activeClass`. Opening and closing emit `open`
 * and `close` on the row, which the lists listen for to render their contents
 * lazily.
 */
app.views.ListFold = class ListFold extends app.View {
  static targetClass = "_list-dir";
  static handleClass = "_list-arrow";
  static activeClass = "open";

  static events = { click: "onClick" };

  static shortcuts = {
    left: "onLeft",
    right: "onRight",
  };

  /** @param {any} el The row to expand. */
  open(el) {
    if (el && !el.classList.contains(this.statics().activeClass)) {
      el.classList.add(this.statics().activeClass);
      $.trigger(el, "open");
    }
  }

  /** @param {any} el The row to collapse. */
  close(el) {
    if (el && el.classList.contains(this.statics().activeClass)) {
      el.classList.remove(this.statics().activeClass);
      $.trigger(el, "close");
    }
  }

  /** @param {any} el */
  toggle(el) {
    if (el.classList.contains(this.statics().activeClass)) {
      this.close(el);
    } else {
      this.open(el);
    }
  }

  /** Collapses every expanded row. */
  reset() {
    let el;
    while ((el = this.findByClass(this.statics().activeClass))) {
      this.close(el);
    }
  }

  /** @returns {any} The focused row, or the selected one. */
  getCursor() {
    return (
      this.findByClass(app.views.ListFocus.activeClass) ||
      this.findByClass(app.views.ListSelect.activeClass)
    );
  }

  /** Collapses the row under the cursor. */
  onLeft() {
    const cursor = this.getCursor();
    if (cursor?.classList?.contains(this.statics().activeClass)) {
      this.close(cursor);
    }
  }

  /** Expands the row under the cursor. */
  onRight() {
    const cursor = this.getCursor();
    if (
      cursor != null
        ? cursor.classList.contains(this.statics().targetClass)
        : undefined
    ) {
      this.open(cursor);
    }
  }

  /** @param {ViewMouseEvent} event */
  onClick(event) {
    if (event.which !== 1 || event.metaKey || event.ctrlKey) {
      return;
    }
    if (!event.pageY) {
      return;
    } // ignore fabricated clicks
    let el = $.eventTarget(event);
    if (el.parentNode.tagName.toUpperCase() === "SVG") {
      el = el.parentNode;
    }

    if (el.classList.contains(this.statics().handleClass)) {
      $.stopEvent(event);
      this.toggle(el.parentNode);
    } else if (el.classList.contains(this.statics().targetClass)) {
      if (el.hasAttribute("href")) {
        if (el.classList.contains(this.statics().activeClass)) {
          if (el.classList.contains(app.views.ListSelect.activeClass)) {
            this.close(el);
          }
        } else {
          this.open(el);
        }
      } else {
        this.toggle(el);
      }
    }
  }
};
