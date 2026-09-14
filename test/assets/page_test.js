// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { page } from "../../assets/javascripts/lib/page.js";

/**
 * Replaces a global that the module reads directly. `location` is getter-only
 * on the Node global, so it has to be defined rather than assigned.
 *
 * @param {string} name
 * @param {unknown} value
 */
const define = (name, value) =>
  Object.defineProperty(globalThis, name, {
    value,
    writable: true,
    configurable: true,
  });

// `page.replace` runs on every navigation and on boot, by way of
// `app.start` -> `router.start` -> `page.start`. It used to cache the
// canonical link element on `this`, which was the global object while the
// assets were one concatenated script; as a module it is undefined, and the
// whole app failed to boot on a TypeError. Exercise the path rather than
// trusting that the modules merely parse.
test("navigating points the canonical link at the current path", () => {
  const link = {
    /** @type {Record<string, string>} */ attrs: {},
    /** @param {string} k @param {string} v */
    setAttribute(k, v) {
      this.attrs[k] = v;
    },
  };

  Object.defineProperty(globalThis.document, "head", {
    value: {
      querySelector: (/** @type {string} */ selector) =>
        selector === 'link[rel="canonical"]' ? link : null,
    },
    writable: true,
    configurable: true,
  });
  define("location", {
    hash: "",
    href: "https://devdocs.io/css/",
    host: "devdocs.io",
    pathname: "/css/",
    search: "",
  });
  define("history", { replaceState() {}, pushState() {} });

  page.replace("/css/", null, true, true);

  assert.equal(link.attrs.href, "https://devdocs.io/css/");
});
