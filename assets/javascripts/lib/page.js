/*
 * Based on github.com/visionmedia/page.js
 * Licensed under the MIT license
 * Copyright 2012 TJ Holowaychuk <tj@vision-media.ca>
 */

// @ts-check

/**
 * The history entry behind a navigation. Stored in `history.state`, so it
 * survives reloads and has to stay JSON-serializable.
 *
 * @typedef {object} PageState
 * @property {number} [id] Incrementing, so that the initial and last entries can be recognized.
 * @property {number} [sessionId] Identifies the page load; a mismatch means the state outlived its session.
 * @property {string} [path]
 */

/**
 * A named capture in a route pattern.
 *
 * @typedef {object} RouteKey
 * @property {string} name
 * @property {boolean} optional
 */

/**
 * A route callback. Calling `next` passes the context on to the route after it.
 *
 * @callback PageCallback
 * @param {Context} context
 * @param {() => unknown} next
 * @returns {unknown}
 */

/**
 * `page` is the router. Its behaviour depends on what it is handed:
 *
 *   - `page(fn)` registers `fn` for every path,
 *   - `page(path, fn)` registers `fn` for one route,
 *   - `page(path, state)` navigates, and
 *   - `page(options)` starts the router.
 *
 * The signatures below are the source of truth for the global, which is
 * declared in globals.d.ts.
 *
 * @callback PageFn
 * @param {string | RegExp | PageCallback | object} [value]
 * @param {PageCallback | PageState} [fn]
 * @returns {void}
 */

/**
 * @typedef {object} PageHelpers
 * @property {(options?: object) => void} start Begins listening for clicks and history changes.
 * @property {() => void} stop
 * @property {(path: string, state?: PageState) => Context | undefined} show Navigates, pushing a history entry.
 * @property {(path: string, state?: PageState, skipDispatch?: boolean, init?: boolean) => Context} replace Navigates, replacing the current history entry.
 * @property {(context: Context) => any} dispatch Runs the context through the registered routes.
 * @property {() => boolean} canGoBack
 * @property {() => boolean} canGoForward
 * @property {(fn: () => void) => void} track Registers an analytics callback, run on every navigation once consent is given.
 */

let running = false;

/** @type {PageState | null} */
let currentState = null;

/** @type {PageCallback[]} */
const callbacks = [];

// The helpers are attached to `page` below, so the function on its own doesn't
// yet satisfy the type the global is declared with.
this.page = /** @type {PageFn & PageHelpers} */ (
  /** @type {PageFn} */ (
    function (value, fn) {
      if (typeof value === "function") {
        page("*", /** @type {PageCallback} */ (value));
      } else if (typeof fn === "function") {
        const route = new Route(/** @type {string | RegExp | string[]} */ (value));
        callbacks.push(route.middleware(fn));
      } else if (typeof value === "string") {
        page.show(value, /** @type {PageState} */ (fn));
      } else {
        page.start(value);
      }
    }
  )
);

page.start = function (options) {
  if (options == null) {
    options = {};
  }
  if (!running) {
    running = true;
    // The app restores scroll positions itself (see app.views.Content), which
    // the browser's automatic restoration would race with and override.
    if ("scrollRestoration" in history) {
      history.scrollRestoration = "manual";
    }
    addEventListener("popstate", onpopstate);
    addEventListener("click", onclick);
    page.replace(currentPath(), null, null, true);
  }
};

page.stop = function () {
  if (running) {
    running = false;
    removeEventListener("click", onclick);
    removeEventListener("popstate", onpopstate);
  }
};

page.show = function (path, state) {
  if (path === currentState?.path) {
    return;
  }
  const context = new Context(path, state);
  const previousState = currentState;
  currentState = context.state;
  const res = page.dispatch(context);
  if (res) {
    currentState = previousState;
    location.assign(res);
  } else {
    context.pushState();
    updateCanonicalLink();
    track();
  }
  return context;
};

page.replace = function (path, state, skipDispatch, init) {
  let result;
  let context = new Context(path, state || currentState);
  context.init = init;
  currentState = context.state;
  if (!skipDispatch) {
    result = page.dispatch(context);
  }
  if (result) {
    context = new Context(result);
    context.init = init;
    currentState = context.state;
    page.dispatch(context);
  }
  context.replaceState();
  updateCanonicalLink();
  if (!skipDispatch) {
    track();
  }
  return context;
};

page.dispatch = function (context) {
  let i = 0;
  const next = function () {
    let fn = callbacks[i++];
    return fn?.(context, next);
  };
  return next();
};

page.canGoBack = () => !Context.isInitialState(currentState);

page.canGoForward = () => !Context.isLastState(currentState);

const currentPath = () => location.pathname + location.search + location.hash;

class Context {
  /**
   * The number of states created so far; also the ID of the next state.
   */
  static stateId = 0;

  /**
   * The session ID to apply across all contexts.
   */
  static sessionId = Date.now();

  /**
   * The path the document was loaded with.
   */
  static initialPath = currentPath();

  /**
   * Whether the state is the first of the session.
   *
   * @param {PageState} state
   * @returns {boolean}
   */
  static isInitialState(state) {
    return state.id === 0;
  }

  /**
   * Whether the state is the most recent one created.
   *
   * @param {PageState} state
   * @returns {boolean}
   */
  static isLastState(state) {
    return state.id === Context.stateId - 1;
  }

  /**
   * Whether a popstate is the browser restoring the path the document loaded with.
   *
   * @param {PageState} state
   * @returns {boolean}
   */
  static isInitialPopState(state) {
    return state.path === Context.initialPath && Context.stateId === 1;
  }

  /**
   * Whether the state was created by this page load.
   *
   * @param {PageState} state
   * @returns {boolean}
   */
  static isSameSession(state) {
    return state.sessionId === Context.sessionId;
  }

  /**
   * Whether this context is the one the document was loaded with, rather than
   * a later navigation. Set by `page.replace`.
   *
   * @type {boolean | undefined}
   */
  init;

  /**
   * The route's captured parameters, by name for named ones and by position
   * for the rest. Set by `Route#middleware` when the route matches.
   *
   * An array that also carries the named captures as string keys, so it is
   * left untyped.
   *
   * @type {any}
   */
  params;

  /**
   * The models the route resolved the path to, set by app/router.js.
   *
   * @type {any}
   */
  doc;

  /** @type {any} */
  entry;

  /** @type {any} */
  type;

  /** The static page the route resolved to, if any. @type {string | undefined} */
  page;

  /** The query string, without the leading `?`. @type {string | undefined} */
  query;

  /** The hash fragment, without the leading `#`. @type {string | undefined} */
  hash;

  /**
   * @param {string} [path] Defaults to `"/"`.
   * @param {PageState} [state]
   */
  constructor(path, state) {
    if (path == null) {
      path = "/";
    }
    this.path = path;
    if (state == null) {
      state = {};
    }
    this.state = state;
    this.pathname = this.path.replace(
      /(?:\?([^#]*))?(?:#(.*))?$/,
      (_, query, hash) => {
        this.query = query;
        this.hash = hash;
        return "";
      },
    );

    if (this.state.id == null) {
      this.state.id = Context.stateId++;
    }
    if (this.state.sessionId == null) {
      this.state.sessionId = Context.sessionId;
    }
    this.state.path = this.path;
  }

  /** Adds a history entry for this context. */
  pushState() {
    history.pushState(this.state, "", this.path);
  }

  /** Replaces the current history entry with this context. */
  replaceState() {
    try {
      history.replaceState(this.state, "", this.path);
    } catch (error) {} // NS_ERROR_FAILURE in Firefox
  }
}

/** A single route: a path pattern, and the parameter names it captures. */
class Route {
  /**
   * @param {string | RegExp | string[]} path
   * @param {object} [options] Unused; kept for call-site compatibility.
   */
  constructor(path, options) {
    this.path = path;
    if (options == null) {
      options = {};
    }
    /** @type {RouteKey[]} */
    this.keys = [];
    this.regexp = pathToRegexp(this.path, this.keys);
  }

  /**
   * Wraps `fn` so that it only runs when the route matches.
   *
   * @param {PageCallback} fn
   * @returns {PageCallback}
   */
  middleware(fn) {
    return (context, next) => {
      // Named captures are set as string keys alongside the positional ones.
      /** @type {unknown} */
      let params = [];
      if (this.match(context.pathname, params)) {
        context.params = params;
        return fn(context, next);
      } else {
        return next();
      }
    };
  }

  /**
   * @param {string} path
   * @param {any} params Filled in with the captured parameters.
   * @returns {boolean | undefined} `undefined` when the route doesn't match.
   */
  match(path, params) {
    const matchData = this.regexp.exec(path);
    if (!matchData) {
      return;
    }

    const iterable = matchData.slice(1);
    for (let i = 0; i < iterable.length; i++) {
      var key = this.keys[i];
      var value = iterable[i];
      if (typeof value === "string") {
        value = decodeURIComponent(value);
      }
      if (key) {
        params[key.name] = value;
      } else {
        params.push(value);
      }
    }
    return true;
  }
}

/**
 * Compiles a path pattern into a regexp, collecting the named captures.
 *
 * @param {string | RegExp | string[]} path
 * @param {RouteKey[]} keys Filled in with one entry per named capture.
 * @returns {RegExp}
 */
var pathToRegexp = function (path, keys) {
  if (path instanceof RegExp) {
    return path;
  }

  if (path instanceof Array) {
    path = `(${path.join("|")})`;
  }
  path = path
    .replace(/\/\(/g, "(?:/")
    .replace(
      /(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?/g,
      (_, slash, format, key, capture, optional) => {
        if (slash == null) {
          slash = "";
        }
        if (format == null) {
          format = "";
        }
        keys.push({ name: key, optional: !!optional });
        let str = optional ? "" : slash;
        str += "(?:";
        if (optional) {
          str += slash;
        }
        str += format;
        str += capture || (format ? "([^/.]+?)" : "([^/]+?)");
        str += ")";
        if (optional) {
          str += optional;
        }
        return str;
      },
    )
    .replace(/([\/.])/g, "\\$1")
    .replace(/\*/g, "(.*)");

  return new RegExp(`^${path}$`);
};

/** @type {(this: Window, ev: PopStateEvent) => any} */
var onpopstate = function (event) {
  if (!event.state || Context.isInitialPopState(event.state)) {
    return;
  }

  if (Context.isSameSession(event.state)) {
    page.replace(event.state.path, event.state);
  } else {
    location.reload();
  }
};

/** @type {(this: Window, ev: PointerEvent) => any} */
var onclick = function (event) {
  try {
    if (
      event.which !== 1 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.defaultPrevented
    ) {
      return;
    }
  } catch (error) {
    return;
  }

  let link = $.eventTarget(event);
  while (link && !(link.tagName === "A" || link.tagName === "a")) {
    link = link.parentNode;
  }

  if (!link) return;

  // If the `<a>` is in an SVG, its attributes are `SVGAnimatedString`s
  // instead of strings
  let href = link.href instanceof SVGAnimatedString
    ? new URL(link.href.baseVal, location.href).href
    : link.href;
  let target = link.target instanceof SVGAnimatedString
    ? link.target.baseVal
    : link.target;

  if (!target && isSameOrigin(href)) {
    event.preventDefault();
    let parsedHref = new URL(href);
    let path = parsedHref.pathname + parsedHref.search + parsedHref.hash;
    path = path.replace(/^\/\/+/, "/"); // IE11 bug
    page.show(path);
  }
};

/** @param {string} url */
var isSameOrigin = (url) =>
  url.startsWith(`${location.protocol}//${location.hostname}`);

/** Points the canonical link at the current path. */
var updateCanonicalLink = function () {
  // Cached on the global, which is what `this` is in the concatenated bundle.
  const self = /** @type {any} */ (this);
  if (!self.canonicalLink) {
    self.canonicalLink = document.head.querySelector('link[rel="canonical"]');
  }
  return self.canonicalLink.setAttribute(
    "href",
    `https://${location.host}${location.pathname}`,
  );
};

/** @type {Array<() => void>} */
const trackers = [];

/** @param {() => void} fn */
page.track = function (fn) {
  trackers.push(fn);
};

var track = function () {
  if (app.config.env !== "production") {
    return;
  }
  if (navigator.doNotTrack === "1") {
    return;
  }
  if (navigator.globalPrivacyControl) {
    return;
  }

  const consentGiven = Cookies.get("analyticsConsent");
  const consentAsked = Cookies.get("analyticsConsentAsked");

  if (consentGiven === "1") {
    for (var tracker of trackers) {
      tracker.call(undefined);
    }
  } else if (consentGiven === undefined && consentAsked === undefined) {
    // Only ask for consent once per browser session
    Cookies.set("analyticsConsentAsked", "1");

    new app.views.Notif("AnalyticsConsent", { autoHide: null });
  }
};

/** Expires the analytics cookies, which are the ones prefixed with a single `_`. */
this.resetAnalytics = function () {
  for (var cookie of document.cookie.split(/;\s?/)) {
    var name = cookie.split("=")[0];
    if (name[0] === "_" && name[1] !== "_") {
      Cookies.expire(name);
    }
  }
};
