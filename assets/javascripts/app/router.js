// @ts-check

import { app } from "./app.js";
import { Events } from "../lib/events.js";
import { page } from "../lib/page.js";
/** @import { Context } from "../lib/page.js" */

/**
 * Maps paths to route events.
 *
 * Each entry in `routes` names a method, which is registered with `page` in
 * order. A handler either triggers its route event and returns nothing, or
 * returns a path to redirect to, or calls `next` to fall through.
 */
export class Router extends Events {
  static routes = [
    ["*", "before"],
    ["/", "root"],
    ["/settings", "settings"],
    ["/offline", "offline"],
    ["/about", "about"],
    ["/news", "news"],
    ["/help", "help"],
    ["/:doc-:type/", "type"],
    ["/:doc/", "doc"],
    ["/:doc/:path(*)", "entry"],
    ["*", "notFound"],
  ];

  /** Registers every route with `page` and normalizes the initial path. */
  constructor() {
    super();
    for (var [path, method] of Router.routes) {
      page(path, this[method].bind(this));
    }
    this.setInitialPath();
  }

  /** Begins routing, dispatching the current path. */
  start() {
    page.start();
  }

  /** @param {string} path */
  show(path) {
    page.show(path);
  }

  /**
   * Navigates without leaving a history entry behind.
   *
   * @param {string} path
   */
  replace(path) {
    page.replace(path);
  }

  /**
   * Emits the route's event, then `after`.
   *
   * @param {string} name
   */
  triggerRoute(name) {
    this.trigger(name, this.context);
    this.trigger("after", name, this.context);
  }

  /**
   * @param {Context} context
   * @param {() => unknown} next
   * @returns {unknown} A path to redirect to, or nothing when the route handled it.
   */
  before(context, next) {
    const previousContext = this.context;
    this.context = context;
    this.trigger("before", context);

    const res = next();
    if (res) {
      this.context = previousContext;
      return res;
    } else {
      return;
    }
  }

  /**
   * @param {Context} context
   * @param {() => unknown} next
   * @returns {unknown} A path to redirect to, or nothing when the route handled it.
   */
  doc(context, next) {
    let doc;
    if (
      (doc =
        app.docs.findBySlug(context.params.doc) ||
        app.disabledDocs.findBySlug(context.params.doc))
    ) {
      context.doc = doc;
      context.entry = doc.toEntry();
      this.triggerRoute("entry");
      return;
    } else {
      return next();
    }
  }

  /**
   * @param {Context} context
   * @param {() => unknown} next
   * @returns {unknown} A path to redirect to, or nothing when the route handled it.
   */
  type(context, next) {
    const doc = app.docs.findBySlug(context.params.doc);
    const type = doc?.types?.findBy("slug", context.params.type);

    if (type) {
      context.doc = doc;
      context.type = type;
      this.triggerRoute("type");
      return;
    } else {
      return next();
    }
  }

  /**
   * @param {Context} context
   * @param {() => unknown} next
   * @returns {unknown} A path to redirect to, or nothing when the route handled it.
   */
  entry(context, next) {
    const doc = app.docs.findBySlug(context.params.doc);
    if (!doc) {
      return next();
    }
    let { path } = context.params;
    const { hash } = context;

    let entry = doc.findEntryByPathAndHash(path, hash);
    if (entry) {
      context.doc = doc;
      context.entry = entry;
      this.triggerRoute("entry");
      return;
    } else if (path.slice(-6) === "/index") {
      path = path.substr(0, path.length - 6);
      entry = doc.findEntryByPathAndHash(path, hash);
      if (entry) {
        return entry.fullPath();
      }
    } else {
      path = `${path}/index`;
      entry = doc.findEntryByPathAndHash(path, hash);
      if (entry) {
        return entry.fullPath();
      }
    }

    return next();
  }

  /** @returns {string | undefined} */
  root() {
    if (app.isSingleDoc()) {
      return "/";
    }
    this.triggerRoute("root");
  }

  /**
   * @param {Context} context
   * @returns {string | undefined} A redirect to the hash form when in single-doc mode.
   */
  settings(context) {
    if (app.isSingleDoc()) {
      return `/#/${context.path}`;
    }
    this.triggerRoute("settings");
  }

  /**
   * @param {Context} context
   * @returns {string | undefined} A redirect to the hash form when in single-doc mode.
   */
  offline(context) {
    if (app.isSingleDoc()) {
      return `/#/${context.path}`;
    }
    this.triggerRoute("offline");
  }

  /**
   * @param {Context} context
   * @returns {string | undefined} A redirect to the hash form when in single-doc mode.
   */
  about(context) {
    if (app.isSingleDoc()) {
      return `/#/${context.path}`;
    }
    context.page = "about";
    this.triggerRoute("page");
  }

  /**
   * @param {Context} context
   * @returns {string | undefined} A redirect to the hash form when in single-doc mode.
   */
  news(context) {
    if (app.isSingleDoc()) {
      return `/#/${context.path}`;
    }
    context.page = "news";
    this.triggerRoute("page");
  }

  /**
   * @param {Context} context
   * @returns {string | undefined} A redirect to the hash form when in single-doc mode.
   */
  help(context) {
    if (app.isSingleDoc()) {
      return `/#/${context.path}`;
    }
    context.page = "help";
    this.triggerRoute("page");
  }

  /** @param {unknown} context */
  notFound(context) {
    this.triggerRoute("notFound");
  }

  /** @returns {boolean} Whether the current page is the doc or app index. */
  isIndex() {
    return (
      this.context?.path === "/" ||
      (app.isSingleDoc() && this.context?.entry?.isIndex())
    );
  }

  /** @returns {boolean} */
  isSettings() {
    return this.context?.path === "/settings";
  }

  /**
   * Normalizes the path the document was loaded with, and follows the
   * `#/path` form that single-doc mode redirects through.
   */
  setInitialPath() {
    // Remove superfluous forward slashes at the beginning of the path
    let path = location.pathname.replace(/^\/{2,}/g, "/");
    if (path !== location.pathname) {
      page.replace(path + location.search + location.hash, null, true);
    }

    if (location.pathname === "/") {
      if ((path = this.getInitialPathFromHash())) {
        page.replace(path + location.search, null, true);
      }
    }
  }

  /** @returns {string | undefined} The path encoded in the hash, if there is one. */
  getInitialPathFromHash() {
    try {
      return new RegExp("#/(.+)").exec(decodeURIComponent(location.hash))?.[1];
    } catch (error) {}
  }

  /**
   * Replaces the hash without dispatching a route.
   *
   * @param {string} [hash] Including the leading `#`.
   */
  replaceHash(hash) {
    page.replace(
      location.pathname + location.search + (hash || ""),
      null,
      true
    );
  }
}
