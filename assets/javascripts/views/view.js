// @ts-check

/**
 * A DOM event as a view handler reads it.
 *
 * lib.dom types `Event#target` as a bare `EventTarget`, which carries none of
 * the element properties a handler reads. The handlers here are bound to
 * elements, so the target is narrowed to one; the form variants narrow it
 * further, for the handlers bound to a field.
 *
 * @typedef {Event & { target: HTMLElement, currentTarget: HTMLElement }} ViewEvent
 * @typedef {MouseEvent & { target: HTMLElement, currentTarget: HTMLElement }} ViewMouseEvent
 * @typedef {KeyboardEvent & { target: HTMLElement, currentTarget: HTMLElement }} ViewKeyboardEvent
 * @typedef {Event & { target: HTMLInputElement, currentTarget: HTMLElement }} ViewInputEvent
 */

/**
 * The static configuration a view subclass declares.
 *
 * The statics below `shortcuts` are the ones subclasses add of their own and
 * read back through `statics()`, which is why they are listed here rather than
 * on each subclass.
 *
 * @typedef {{
 *   el?: string | Element | Document,
 *   tagName?: string,
 *   className?: string,
 *   attributes?: Record<string, string>,
 *   elements?: Record<string, string>,
 *   events?: Record<string, string>,
 *   routes?: Record<string, string>,
 *   shortcuts?: Record<string, string>,
 *   activeClass?: string,
 *   targetClass?: string,
 *   handleClass?: string,
 *   itemClass?: string,
 *   loadingClass?: string,
 *   errorClass?: string,
 *   defaultOptions?: Record<string, any>,
 *   titles?: Record<string, string>,
 * }} ViewStatics
 */

/**
 * The base view: an element, the subviews under it, and the events it is
 * bound to.
 *
 * A subclass declares what it needs with the statics above; the constructor
 * builds or finds the element, applies them, and calls `init` if the subclass
 * defines one. Bindings are only live between `activate` and `deactivate`.
 */
class View extends Events {
  /**
   * The element the view is bound to.
   *
   * A view can also bind to the document (see views/layout/document.js); such
   * a view reaches for `document` directly rather than through `el`.
   *
   * @type {HTMLElement}
   */
  el;

  /** @param {HTMLElement} [el] The element to bind to. Built from the statics when absent. */
  constructor(el) {
    super();
    if (el instanceof HTMLElement) {
      this.el = el;
    }
    this.setupElement();
    if (this.el.className) {
      this.originalClassName = this.el.className;
    }
    if (this.statics().className) {
      this.resetClass();
    }
    this.refreshElements();
    // `init` is an optional hook, defined on the subclass's prototype.
    const self = /** @type {{ init?: () => void }} */ (this);
    if (typeof self.init === "function") {
      self.init();
      this.refreshElements();
    }
  }

  /**
   * The subclass's static configuration. `this.constructor` is typed as a bare
   * `Function`, so it needs narrowing before the statics can be read.
   *
   * @returns {ViewStatics}
   */
  statics() {
    return /** @type {ViewStatics} */ (this.constructor);
  }

  /** Finds or builds the element, and applies the static attributes to it. */
  setupElement() {
    const statics = this.statics();
    if (this.el == null) {
      this.el =
        typeof statics.el === "string"
          ? $(statics.el)
          : statics.el
            ? // A view may bind to the document; see the note on `el`.
              /** @type {HTMLElement} */ (/** @type {unknown} */ (statics.el))
            : document.createElement(statics.tagName || "div");
    }

    if (statics.attributes) {
      for (var key in statics.attributes) {
        var value = statics.attributes[key];
        this.el.setAttribute(key, value);
      }
    }
  }

  /** Re-resolves the static `elements` selectors onto instance properties. */
  refreshElements() {
    const statics = this.statics();
    if (statics.elements) {
      for (var name in statics.elements) {
        var selector = statics.elements[name];
        /** @type {Record<string, unknown>} */ (this)[name] = this.find(selector);
      }
    }
  }

  /** @param {string} name */
  addClass(name) {
    this.el.classList.add(name);
  }

  /** @param {string} name */
  removeClass(name) {
    this.el.classList.remove(name);
  }

  /** @param {string} name */
  toggleClass(name) {
    this.el.classList.toggle(name);
  }

  /**
   * @param {string} name
   * @returns {boolean}
   */
  hasClass(name) {
    return this.el.classList.contains(name);
  }

  /** Restores the element's original classes, then reapplies the static ones. */
  resetClass() {
    this.el.className = this.originalClassName || "";
    const { className } = this.statics();
    if (className) {
      for (var name of Array.from(className.split(" "))) {
        this.addClass(name);
      }
    }
  }

  /**
   * @param {string} selector
   * @returns {any} The first match inside the view, or `undefined`.
   */
  find(selector) {
    return $(selector, this.el);
  }

  /**
   * @param {string} selector
   * @returns {NodeListOf<any>} Every match inside the view.
   */
  findAll(selector) {
    return $$(selector, this.el);
  }

  /**
   * @param {string} name
   * @returns {unknown} The first match, or `undefined`.
   */
  findByClass(name) {
    return this.findAllByClass(name)[0];
  }

  /**
   * @param {string} name
   * @returns {unknown} The last match, or `undefined`.
   */
  findLastByClass(name) {
    const all = this.findAllByClass(name);
    return all[all.length - 1];
  }

  /**
   * @param {string} name
   * @returns {HTMLCollectionOf<any>} A live collection.
   */
  findAllByClass(name) {
    return this.el.getElementsByClassName(name);
  }

  /**
   * @param {string} tag
   * @returns {any} The first match, or `undefined`.
   */
  findByTag(tag) {
    return this.findAllByTag(tag)[0];
  }

  /**
   * @param {string} tag
   * @returns {unknown} The last match, or `undefined`.
   */
  findLastByTag(tag) {
    const all = this.findAllByTag(tag);
    return all[all.length - 1];
  }

  /**
   * @param {string} tag
   * @returns {HTMLCollectionOf<any>} A live collection.
   */
  findAllByTag(tag) {
    return this.el.getElementsByTagName(tag);
  }

  /** @param {any} value Markup, a node, or another view. */
  append(value) {
    $.append(this.el, value.el || value);
  }

  /** @param {any} value The node or view to append this one to. */
  appendTo(value) {
    $.append(value.el || value, this.el);
  }

  /** @param {any} value Markup, a node, or another view. */
  prepend(value) {
    $.prepend(this.el, value.el || value);
  }

  /** @param {any} value The node or view to prepend this one to. */
  prependTo(value) {
    $.prepend(value.el || value, this.el);
  }

  /** @param {any} value Markup, a node, or another view, inserted before this one. */
  before(value) {
    $.before(this.el, value.el || value);
  }

  /** @param {any} value Markup, a node, or another view, inserted after this one. */
  after(value) {
    $.after(this.el, value.el || value);
  }

  /** @param {any} value The node or view to detach. */
  remove(value) {
    $.remove(value.el || value);
  }

  /** Removes every child, then re-resolves the `elements` statics. */
  empty() {
    $.empty(this.el);
    this.refreshElements();
  }

  /**
   * Replaces the view's contents.
   *
   * @param {unknown} value Markup, a node, or another view.
   */
  html(value) {
    this.empty();
    this.append(value);
  }

  /**
   * Renders one of `app.templates`.
   *
   * @param {...unknown} args The template name, then its arguments.
   * @returns {string}
   */
  tmpl(...args) {
    return app.templates.render(...args);
  }

  /**
   * Runs `fn` bound to the view, later.
   *
   * @param {Function} fn
   * @param {...any} args Arguments for `fn`, optionally followed by a delay in milliseconds.
   * @returns {any} The timeout handle.
   */
  delay(fn, ...args) {
    const delay = typeof args[args.length - 1] === "number" ? args.pop() : 0;
    return setTimeout(fn.bind(this, ...args), delay);
  }

  /**
   * @param {string} event One or more event names, separated by spaces.
   * @param {(event: unknown) => void} callback
   */
  onDOM(event, callback) {
    $.on(this.el, event, callback);
  }

  /**
   * @param {string} event One or more event names, separated by spaces.
   * @param {(event: unknown) => void} callback
   */
  offDOM(event, callback) {
    $.off(this.el, event, callback);
  }

  /** Binds the DOM events, routes and shortcuts named in the statics. */
  bindEvents() {
    let method, name;
    const statics = this.statics();
    if (statics.events) {
      for (name in statics.events) {
        method = statics.events[name];
        /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method] = /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method].bind(this);
        this.onDOM(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method] = /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method].bind(this);
        app.router.on(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method] = /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method].bind(this);
        app.shortcuts.on(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }
  }

  /** Unbinds what `bindEvents` bound. */
  unbindEvents() {
    let method, name;
    const statics = this.statics();
    if (statics.events) {
      for (name in statics.events) {
        method = statics.events[name];
        this.offDOM(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        app.router.off(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        app.shortcuts.off(name, /** @type {Record<string, (...args: unknown[]) => void>} */ (this)[method]);
      }
    }
  }

  /**
   * Registers a view to be activated and deactivated along with this one.
   *
   * @param {unknown} view
   * @returns {number} The number of subviews.
   */
  addSubview(view) {
    return (this.subviews || (this.subviews = [])).push(view);
  }

  /**
   * Binds the view's events, and its subviews'. Does nothing if already active.
   *
   * @returns {boolean | void} `true` when it went from inactive to active.
   */
  activate() {
    if (this.activated) {
      return;
    }
    this.bindEvents();
    if (this.subviews) {
      for (var view of Array.from(this.subviews)) {
        view.activate();
      }
    }
    this.activated = true;
    return true;
  }

  /**
   * Unbinds the view's events, and its subviews'. Does nothing if not active.
   *
   * @returns {boolean | void} `true` when it went from active to inactive.
   */
  deactivate() {
    if (!this.activated) {
      return;
    }
    this.unbindEvents();
    if (this.subviews) {
      for (var view of Array.from(this.subviews)) {
        view.deactivate();
      }
    }
    this.activated = false;
    return true;
  }

  /** Deactivates the view and takes its element out of the document. */
  detach() {
    this.deactivate();
    $.remove(this.el);
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that subclasses extend a type rather than `any`.
app.View = View;
