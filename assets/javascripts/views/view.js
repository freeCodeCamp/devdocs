// @ts-check

/**
 * The static configuration a view subclass declares.
 *
 * @typedef {object} ViewStatics
 * @property {string | Element} [el] The element to bind to, as a selector or directly. A new one is created when absent.
 * @property {string} [tagName] The tag to create when there is no `el`. Defaults to `div`.
 * @property {string} [className] Space-separated classes to apply to the element.
 * @property {Record<string, string>} [attributes] Attributes to set on the element.
 * @property {Record<string, string>} [elements] Instance properties to look up, by selector.
 * @property {Record<string, string>} [events] Method names to bind, by DOM event.
 * @property {Record<string, string>} [routes] Method names to bind, by route event.
 * @property {Record<string, string>} [shortcuts] Method names to bind, by shortcut event.
 *
 * Subclasses add their own statics — class names, titles, and so on — which
 * this index signature keeps reachable without listing each of them here.
 * @property {any} [key]
 */

/**
 * The base view: an element, the subviews under it, and the events it is
 * bound to.
 *
 * A subclass declares what it needs with the statics above; the constructor
 * builds or finds the element, applies them, and calls `init` if the subclass
 * defines one. Bindings are only live between `activate` and `deactivate`.
 */
app.View = class View extends Events {
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
    const self = /** @type {any} */ (this);
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
    return /** @type {any} */ (this.constructor);
  }

  /** Finds or builds the element, and applies the static attributes to it. */
  setupElement() {
    const statics = this.statics();
    if (this.el == null) {
      this.el =
        typeof statics.el === "string"
          ? $(statics.el)
          : statics.el
            ? statics.el
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
        /** @type {any} */ (this)[name] = this.find(selector);
      }
    }
  }

  addClass(name) {
    this.el.classList.add(name);
  }

  removeClass(name) {
    this.el.classList.remove(name);
  }

  toggleClass(name) {
    this.el.classList.toggle(name);
  }

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

  find(selector) {
    return $(selector, this.el);
  }

  findAll(selector) {
    return $$(selector, this.el);
  }

  findByClass(name) {
    return this.findAllByClass(name)[0];
  }

  /**
   * @param {string} name
   * @returns {Element | undefined}
   */
  findLastByClass(name) {
    const all = this.findAllByClass(name);
    return all[all.length - 1];
  }

  findAllByClass(name) {
    return this.el.getElementsByClassName(name);
  }

  findByTag(tag) {
    return this.findAllByTag(tag)[0];
  }

  findLastByTag(tag) {
    const all = this.findAllByTag(tag);
    return all[all.length - 1];
  }

  findAllByTag(tag) {
    return this.el.getElementsByTagName(tag);
  }

  append(value) {
    $.append(this.el, value.el || value);
  }

  appendTo(value) {
    $.append(value.el || value, this.el);
  }

  prepend(value) {
    $.prepend(this.el, value.el || value);
  }

  prependTo(value) {
    $.prepend(value.el || value, this.el);
  }

  before(value) {
    $.before(this.el, value.el || value);
  }

  after(value) {
    $.after(this.el, value.el || value);
  }

  remove(value) {
    $.remove(value.el || value);
  }

  empty() {
    $.empty(this.el);
    this.refreshElements();
  }

  html(value) {
    this.empty();
    this.append(value);
  }

  tmpl(...args) {
    return app.templates.render(...args);
  }

  delay(fn, ...args) {
    const delay = typeof args[args.length - 1] === "number" ? args.pop() : 0;
    return setTimeout(fn.bind(this, ...args), delay);
  }

  onDOM(event, callback) {
    $.on(this.el, event, callback);
  }

  offDOM(event, callback) {
    $.off(this.el, event, callback);
  }

  bindEvents() {
    let method, name;
    const statics = this.statics();
    if (statics.events) {
      for (name in statics.events) {
        method = statics.events[name];
        /** @type {any} */ (this)[method] = /** @type {any} */ (this)[method].bind(this);
        this.onDOM(name, /** @type {any} */ (this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        /** @type {any} */ (this)[method] = /** @type {any} */ (this)[method].bind(this);
        app.router.on(name, /** @type {any} */ (this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        /** @type {any} */ (this)[method] = /** @type {any} */ (this)[method].bind(this);
        app.shortcuts.on(name, /** @type {any} */ (this)[method]);
      }
    }
  }

  unbindEvents() {
    let method, name;
    const statics = this.statics();
    if (statics.events) {
      for (name in statics.events) {
        method = statics.events[name];
        this.offDOM(name, /** @type {any} */ (this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        app.router.off(name, /** @type {any} */ (this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        app.shortcuts.off(name, /** @type {any} */ (this)[method]);
      }
    }
  }

  addSubview(view) {
    return (this.subviews || (this.subviews = [])).push(view);
  }

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

  detach() {
    this.deactivate();
    $.remove(this.el);
  }
};
