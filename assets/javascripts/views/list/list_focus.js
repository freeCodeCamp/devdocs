// @ts-check

/**
 * Keyboard navigation through a list.
 *
 * The focused row carries `activeClass`; moving the focus emits `focus` and
 * `blur` on the rows. The focus starts from the selected row when nothing is
 * focused yet, and stepping past the end of a page clicks its pagination link
 * so that the next page is rendered first.
 */
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

  /**
   * @param {any} el The row to focus.
   * @param {{ silent?: boolean }} [options] Pass `silent` to move without emitting `focus`.
   */
  focus(el, options) {
    if (options == null) {
      options = {};
    }
    if (el && !el.classList.contains(this.statics().activeClass)) {
      this.blur();
      el.classList.add(this.statics().activeClass);
      if (options.silent !== true) {
        $.trigger(el, "focus");
      }
    }
  }

  /** Clears the focus. */
  blur() {
    const cursor = this.getCursor();
    if (cursor) {
      cursor.classList.remove(this.statics().activeClass);
      $.trigger(cursor, "blur");
    }
  }

  /** @returns {any} The focused row, or the selected one when nothing is focused. */
  getCursor() {
    return (
      this.findByClass(this.statics().activeClass) ||
      this.findByClass(app.views.ListSelect.activeClass)
    );
  }

  /**
   * @param {any} cursor
   * @returns {any} The row after `cursor`, descending into expanded sub-lists.
   */
  findNext(cursor) {
    const next = cursor.nextSibling;
    if (next) {
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

  /**
   * @param {any} cursor
   * @returns {any} The first row of the sub-list under `cursor`.
   */
  findFirst(cursor) {
    const first = cursor.firstChild;
    if (!first) {
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

  /**
   * @param {any} cursor
   * @returns {any} The row before `cursor`, descending into expanded sub-lists.
   */
  findPrev(cursor) {
    const prev = cursor.previousSibling;
    if (prev) {
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

  /**
   * @param {any} cursor
   * @returns {any} The last row of the sub-list under `cursor`.
   */
  findLast(cursor) {
    const last = cursor.lastChild;
    if (!last) {
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

  /** Moves the focus down one row. */
  onDown() {
    const cursor = this.getCursor();
    if (cursor) {
      this.focusOnNextFrame(this.findNext(cursor));
    } else {
      this.focusOnNextFrame(this.findByTag("a"));
    }
  }

  /** Moves the focus up one row. */
  onUp() {
    const cursor = this.getCursor();
    if (cursor) {
      this.focusOnNextFrame(this.findPrev(cursor));
    } else {
      this.focusOnNextFrame(this.findLastByTag("a"));
    }
  }

  /** Moves the focus out to the row the current sub-list hangs off. */
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

  /** Follows the focused row. */
  onEnter() {
    const cursor = this.getCursor();
    if (cursor) {
      $.click(cursor);
    }
  }

  /** Opens the focused row outside the app. */
  onSuperEnter() {
    const cursor = this.getCursor();
    if (cursor) {
      $.popup(cursor);
    }
  }

  /** @param {ViewMouseEvent} event */
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
