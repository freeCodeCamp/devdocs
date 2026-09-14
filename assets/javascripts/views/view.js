// @ts-check

import { app } from "../app/app.js";
import { Events } from "../lib/events.js";
import { $, $$ } from "../lib/util.js";
import { render } from "../templates/base.js";
/** @import { DollarContent } from "../lib/util.js" */

/**
 * Anything a view's manipulation helpers accept as content: markup, a node, a
 * collection of them, or another view.
 *
 * @typedef {DollarContent | View} ViewContent
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
export class View extends Events {
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
        elementSlots(this)[name] = this.find(selector);
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
   * @returns {HTMLElement} The first match inside the view, or `undefined`.
   */
  find(selector) {
    return $(selector, this.el);
  }

  /**
   * @param {string} selector
   * @returns {NodeListOf<HTMLElement>} Every match inside the view.
   */
  findAll(selector) {
    return $$(selector, this.el);
  }

  /**
   * @param {string} name
   * @returns {HTMLElement | undefined} The first match.
   */
  findByClass(name) {
    return this.findAllByClass(name)[0];
  }

  /**
   * @param {string} name
   * @returns {HTMLElement | undefined} The last match.
   */
  findLastByClass(name) {
    const all = this.findAllByClass(name);
    return all[all.length - 1];
  }

  /**
   * @param {string} name
   * @returns {HTMLCollectionOf<HTMLElement>} A live collection.
   */
  findAllByClass(name) {
    return /** @type {HTMLCollectionOf<HTMLElement>} */ (
      this.el.getElementsByClassName(name)
    );
  }

  /**
   * @param {string} tag
   * @returns {HTMLElement | undefined} The first match.
   */
  findByTag(tag) {
    return this.findAllByTag(tag)[0];
  }

  /**
   * @param {string} tag
   * @returns {HTMLElement | undefined} The last match.
   */
  findLastByTag(tag) {
    const all = this.findAllByTag(tag);
    return all[all.length - 1];
  }

  /**
   * @param {string} tag
   * @returns {HTMLCollectionOf<HTMLElement>} A live collection.
   */
  findAllByTag(tag) {
    return /** @type {HTMLCollectionOf<HTMLElement>} */ (
      this.el.getElementsByTagName(tag)
    );
  }

  /** @param {ViewContent} value */
  append(value) {
    $.append(this.el, contentOf(value));
  }

  /** @param {View | HTMLElement} value The element or view to append this one to. */
  appendTo(value) {
    $.append(nodeOf(value), this.el);
  }

  /** @param {ViewContent} value */
  prepend(value) {
    $.prepend(this.el, contentOf(value));
  }

  /** @param {View | HTMLElement} value The element or view to prepend this one to. */
  prependTo(value) {
    $.prepend(nodeOf(value), this.el);
  }

  /** @param {ViewContent} value Inserted before this view. */
  before(value) {
    $.before(this.el, contentOf(value));
  }

  /** @param {ViewContent} value Inserted after this view. */
  after(value) {
    $.after(this.el, contentOf(value));
  }

  /** @param {View | HTMLElement} value The element or view to detach. */
  remove(value) {
    $.remove(nodeOf(value));
  }

  /** Removes every child, then re-resolves the `elements` statics. */
  empty() {
    $.empty(this.el);
    this.refreshElements();
  }

  /**
   * Replaces the view's contents.
   *
   * @param {ViewContent} value
   */
  html(value) {
    this.empty();
    this.append(value);
  }

  /**
   * Renders one of `app.templates`.
   *
   * @param {string} name
   * @param {...unknown} args The template's own arguments.
   * @returns {string}
   */
  tmpl(name, ...args) {
    return render(name, ...args);
  }

  /**
   * Runs `fn` bound to the view, later.
   *
   * @param {Function} fn
   * @param {...unknown} args Arguments for `fn`, optionally followed by a delay in milliseconds.
   * @returns {ReturnType<typeof setTimeout>} The timeout handle.
   */
  delay(fn, ...args) {
    const last = args[args.length - 1];
    const delay = typeof last === "number" ? /** @type {number} */ (args.pop()) : 0;
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
        handlerSlots(this)[method] = handlerSlots(this)[method].bind(this);
        this.onDOM(name, handlerSlots(this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        handlerSlots(this)[method] = handlerSlots(this)[method].bind(this);
        app.router.on(name, handlerSlots(this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        handlerSlots(this)[method] = handlerSlots(this)[method].bind(this);
        app.shortcuts.on(name, handlerSlots(this)[method]);
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
        this.offDOM(name, handlerSlots(this)[method]);
      }
    }

    if (statics.routes) {
      for (name in statics.routes) {
        method = statics.routes[name];
        app.router.off(name, handlerSlots(this)[method]);
      }
    }

    if (statics.shortcuts) {
      for (name in statics.shortcuts) {
        method = statics.shortcuts[name];
        app.shortcuts.off(name, handlerSlots(this)[method]);
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

/**
 * The `elements` static names instance properties by string, so they are
 * written through an index rather than directly.
 *
 * @param {View} view
 * @returns {Record<string, unknown>}
 */
const elementSlots = (view) =>
  /** @type {Record<string, unknown>} */ (/** @type {unknown} */ (view));

/**
 * The `events`, `routes` and `shortcuts` statics name their handlers by
 * string, so they too are reached through an index.
 *
 * @param {View} view
 * @returns {Record<string, (...args: unknown[]) => void>}
 */
const handlerSlots = (view) =>
  /** @type {Record<string, (...args: unknown[]) => void>} */ (
    /** @type {unknown} */ (view)
  );

/**
 * Unwraps a view into its element, leaving markup and nodes alone.
 *
 * @param {ViewContent} value
 * @returns {DollarContent}
 */
const contentOf = (value) => (value instanceof View ? value.el : value);

/**
 * @param {View | HTMLElement} value
 * @returns {HTMLElement}
 */
const nodeOf = (value) => (value instanceof View ? value.el : value);
