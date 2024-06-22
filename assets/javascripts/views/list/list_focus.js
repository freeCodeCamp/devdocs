app.views.ListFocus = class ListFocus extends app.View {
  static activeClass = "focus";

  static events = { click: "onClick" };

  static shortcuts = {
    up: "onUp",
    down: "onDown",
    left: "onLeft",
    enter: "onEnter",
    superEnter: "onSuperEnter",
    escape: "blur",
  };

  constructor(el) {
    super(el);
    this.focusOnNextFrame = (el) => requestAnimationFrame(() => this.focus(el));
  }

  focus(el, options) {
    if (options == null) {
      options = {};
    }
    if (el && !el.classList.contains(this.constructor.activeClass)) {
      this.blur();
      el.classList.add(this.constructor.activeClass);
      if (options.silent !== true) {
        $.trigger(el, "focus");
      }
    }
  }

  blur() {
    let cursor;
    if ((cursor = this.getCursor())) {
      cursor.classList.remove(this.constructor.activeClass);
      $.trigger(cursor, "blur");
    }
  }

  getCursor() {
    return (
      this.findByClass(this.constructor.activeClass) ||
      this.findByClass(app.views.ListSelect.activeClass)
    );
  }

  findNext(cursor) {
    let next;
    if ((next = cursor.nextSibling)) {
      if (next.tagName === "A") {
        return next;
      } else if (next.tagName === "SPAN") {
        // pagination link
        $.click(next);
        return this.findNext(cursor);
      } else if (next.tagName === "DIV") {
        // sub-list
        if (cursor.className.includes(" open")) {
          return this.findFirst(next) || this.findNext(next);
        } else {
          return this.findNext(next);
        }
      } else if (next.tagName === "H6") {
        // title
        return this.findNext(next);
      }
    } else if (cursor.parentNode !== this.el) {
      return this.findNext(cursor.parentNode);
    }
  }

  findFirst(cursor) {
    let first;
    if (!(first = cursor.firstChild)) {
      return;
    }

    if (first.tagName === "A") {
      return first;
    } else if (first.tagName === "SPAN") {
      // pagination link
      $.click(first);
      return this.findFirst(cursor);
    }
  }

  findPrev(cursor) {
    let prev;
    if ((prev = cursor.previousSibling)) {
      if (prev.tagName === "A") {
        return prev;
      } else if (prev.tagName === "SPAN") {
        // pagination link
        $.click(prev);
        return this.findPrev(cursor);
      } else if (prev.tagName === "DIV") {
        // sub-list
        if (prev.previousSibling.className.includes("open")) {
          return this.findLast(prev) || this.findPrev(prev);
        } else {
          return this.findPrev(prev);
        }
      } else if (prev.tagName === "H6") {
        // title
        return this.findPrev(prev);
      }
    } else if (cursor.parentNode !== this.el) {
      return this.findPrev(cursor.parentNode);
    }
  }

  findLast(cursor) {
    let last;
    if (!(last = cursor.lastChild)) {
      return;
    }

    if (last.tagName === "A") {
      return last;
    } else if (last.tagName === "SPAN" || last.tagName === "H6") {
      // pagination link or title
      return this.findPrev(last);
    } else if (last.tagName === "DIV") {
      // sub-list
      return this.findLast(last);
    }
  }

  onDown() {
    let cursor;
    if ((cursor = this.getCursor())) {
      this.focusOnNextFrame(this.findNext(cursor));
    } else {
      this.focusOnNextFrame(this.findByTag("a"));
    }
  }

  onUp() {
    let cursor;
    if ((cursor = this.getCursor())) {
      this.focusOnNextFrame(this.findPrev(cursor));
    } else {
      this.focusOnNextFrame(this.findLastByTag("a"));
    }
  }

  onLeft() {
    const cursor = this.getCursor();
    if (
      cursor &&
      !cursor.classList.contains(app.views.ListFold.activeClass) &&
      cursor.parentNode !== this.el
    ) {
      const prev = cursor.parentNode.previousSibling;
      if (prev && prev.classList.contains(app.views.ListFold.targetClass)) {
        this.focusOnNextFrame(cursor.parentNode.previousSibling);
      }
    }
  }

  onEnter() {
    let cursor;
    if ((cursor = this.getCursor())) {
      $.click(cursor);
    }
  }

  onSuperEnter() {
    let cursor;
    if ((cursor = this.getCursor())) {
      $.popup(cursor);
    }
  }

  onClick(event) {
    if (event.which !== 1 || event.metaKey || event.ctrlKey) {
      return;
    }
    const target = $.eventTarget(event);
    if (target.tagName === "A") {
      this.focus(target, { silent: true });
    }
  }
};
