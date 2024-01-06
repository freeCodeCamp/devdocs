app.views.ListFold = class ListFold extends app.View {
  static targetClass = "_list-dir";
  static handleClass = "_list-arrow";
  static activeClass = "open";

  static events = { click: "onClick" };

  static shortcuts = {
    left: "onLeft",
    right: "onRight",
  };

  open(el) {
    if (el && !el.classList.contains(this.constructor.activeClass)) {
      el.classList.add(this.constructor.activeClass);
      $.trigger(el, "open");
    }
  }

  close(el) {
    if (el && el.classList.contains(this.constructor.activeClass)) {
      el.classList.remove(this.constructor.activeClass);
      $.trigger(el, "close");
    }
  }

  toggle(el) {
    if (el.classList.contains(this.constructor.activeClass)) {
      this.close(el);
    } else {
      this.open(el);
    }
  }

  reset() {
    let el;
    while ((el = this.findByClass(this.constructor.activeClass))) {
      this.close(el);
    }
  }

  getCursor() {
    return (
      this.findByClass(app.views.ListFocus.activeClass) ||
      this.findByClass(app.views.ListSelect.activeClass)
    );
  }

  onLeft() {
    const cursor = this.getCursor();
    if (cursor?.classList?.contains(this.constructor.activeClass)) {
      this.close(cursor);
    }
  }

  onRight() {
    const cursor = this.getCursor();
    if (
      cursor != null
        ? cursor.classList.contains(this.constructor.targetClass)
        : undefined
    ) {
      this.open(cursor);
    }
  }

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

    if (el.classList.contains(this.constructor.handleClass)) {
      $.stopEvent(event);
      this.toggle(el.parentNode);
    } else if (el.classList.contains(this.constructor.targetClass)) {
      if (el.hasAttribute("href")) {
        if (el.classList.contains(this.constructor.activeClass)) {
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
