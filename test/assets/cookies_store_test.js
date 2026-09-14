// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { CookiesStore } from "../../assets/javascripts/lib/cookies_store.js";

// A cookie jar the vendored Cookies.js can write to: keys and values stay
// percent-encoded, as they are on a real `document.cookie`, and a write whose
// expiry has passed deletes the key.
/** @type {Map<string, string>} */
const jar = new Map();
let cookiesAccepted = true;

Object.defineProperty(document, "cookie", {
  get: () =>
    [...jar].map(([key, value]) => `${key}=${value}`).join("; "),
  set: (string) => {
    if (!cookiesAccepted) return;
    const [pair, ...attributes] = string.split(";");
    const separator = pair.indexOf("=");
    const key = pair.slice(0, separator);
    const expires = attributes
      .map((attribute) => attribute.trim())
      .find((attribute) => /^expires=/i.test(attribute));

    if (expires && new Date(expires.slice(8)) <= new Date()) {
      jar.delete(key);
    } else {
      jar.set(key, pair.slice(separator + 1));
    }
  },
  configurable: true,
});

/** @type {Map<string, string>} */
const storage = new Map();

Object.defineProperty(globalThis, "localStorage", {
  value: {
    getItem: (/** @type {string} */ key) =>
      storage.has(key) ? storage.get(key) : null,
    setItem: (/** @type {string} */ key, /** @type {string} */ value) =>
      storage.set(key, String(value)),
    removeItem: (/** @type {string} */ key) => storage.delete(key),
    clear: () => storage.clear(),
  },
  writable: true,
  configurable: true,
});

// The store reads the vendored library off the global, and the library binds
// itself to whatever `window` it is loaded with, so hand it the document above
// before it evaluates.
// @ts-ignore -- the fake window from setup.js has no document until now.
window.document = document;
await import("../../assets/javascripts/vendor/cookies.js");
Object.defineProperty(globalThis, "Cookies", {
  // @ts-ignore -- where the library puts itself under Node.
  value: window.Cookies,
  writable: true,
  configurable: true,
});

/** Wipes both stores, as a fresh browser profile would. */
const reset = () => {
  jar.clear();
  storage.clear();
  cookiesAccepted = true;
};

/** Drops the cookies while leaving localStorage alone, as Safari's seven-day cap does. */
const expireCookies = () => jar.clear();

test("stores and reads back values, parsing the integers", () => {
  reset();
  const store = new CookiesStore();

  store.set("docs", "css/javascript");
  store.set("size", 320);
  store.set("hideIntro", true);

  assert.equal(store.get("docs"), "css/javascript");
  assert.equal(store.get("size"), 320);
  assert.equal(store.get("hideIntro"), 1);
  assert.equal(store.get("missing"), undefined);
});

test("puts back the cookies the browser has dropped", () => {
  reset();
  new CookiesStore().set("docs", "css/javascript");

  expireCookies();
  const store = new CookiesStore();

  assert.equal(store.get("docs"), "css/javascript");
  assert.match(document.cookie, /docs=css\/javascript/);
});

test("puts back the settings of a visitor who has no mirror yet", () => {
  reset();
  // The cookie is there, but predates the mirror, as on the visit that first
  // runs this version of the app.
  document.cookie = "docs=css/javascript";
  new CookiesStore();

  expireCookies();
  assert.equal(new CookiesStore().get("docs"), "css/javascript");
});

test("keeps a value intact when it is restored, rather than re-escaping it", () => {
  reset();
  new CookiesStore().set("layout", "_max-width _sidebar-hidden");

  expireCookies();
  const store = new CookiesStore();

  assert.equal(store.get("layout"), "_max-width _sidebar-hidden");
  assert.deepEqual(store.dump(), { layout: "_max-width _sidebar-hidden" });
});

test("does not put back a deleted value", () => {
  reset();
  const store = new CookiesStore();
  store.set("docs", "css/javascript");
  store.del("docs");

  assert.equal(store.get("docs"), undefined);

  expireCookies();
  assert.equal(new CookiesStore().get("docs"), undefined);
});

test("does not put anything back after a reset", () => {
  reset();
  const store = new CookiesStore();
  store.set("docs", "css/javascript");
  store.set("size", 320);
  store.reset();

  assert.equal(store.get("docs"), undefined);
  assert.deepEqual(new CookiesStore().dump(), {});
});

test("falls back to the mirror, and still reports the block, when cookies are refused", () => {
  reset();
  const store = new CookiesStore();
  /** @type {unknown[]} */
  const blocked = [];
  const onBlocked = CookiesStore.onBlocked;
  CookiesStore.onBlocked = (key, value, actual) =>
    blocked.push([key, value, actual]);

  try {
    cookiesAccepted = false;
    store.set("docs", "css/javascript");

    assert.deepEqual(blocked, [["docs", "css/javascript", undefined]]);
    assert.equal(store.get("docs"), "css/javascript");
    assert.equal(new CookiesStore().get("docs"), "css/javascript");
  } finally {
    CookiesStore.onBlocked = onBlocked;
  }
});

test("keeps a setting another tab has written since the mirror was read", () => {
  reset();
  const tabA = new CookiesStore();
  const tabB = new CookiesStore();

  tabA.set("theme", "dark");
  tabB.set("size", 320);

  expireCookies();
  const store = new CookiesStore();

  assert.equal(store.get("theme"), "dark");
  assert.equal(store.get("size"), 320);
});

test("keeps reading a value whose cookie the browser has refused", () => {
  reset();
  const store = new CookiesStore();
  store.set("docs", "css");

  cookiesAccepted = false;
  store.set("docs", "css/javascript");

  assert.equal(store.get("docs"), "css/javascript");
  assert.deepEqual(store.dump(), { docs: "css/javascript" });
});
