// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { SettingsStore } from "../../assets/javascripts/lib/settings_store.js";

/** @type {Map<string, string>} */
const storage = new Map();
let storageWritable = true;

Object.defineProperty(globalThis, "localStorage", {
  value: {
    getItem: (/** @type {string} */ key) =>
      storage.has(key) ? storage.get(key) : null,
    setItem: (/** @type {string} */ key, /** @type {string} */ value) => {
      if (!storageWritable) throw new Error("storage is full");
      storage.set(key, String(value));
    },
    removeItem: (/** @type {string} */ key) => storage.delete(key),
    clear: () => storage.clear(),
  },
  writable: true,
  configurable: true,
});

// A cookie jar the migration can read and expire: keys and values stay
// percent-encoded, as they are on a real `document.cookie`.
/** @type {Map<string, string>} */
const jar = new Map();

Object.defineProperty(document, "cookie", {
  get: () => [...jar].map(([key, value]) => `${key}=${value}`).join("; "),
  set: (/** @type {string} */ string) => {
    const pair = string.split(";")[0];
    const separator = pair.indexOf("=");
    // The only expiry anything writes is the epoch, which deletes.
    if (/;\s*expires=/i.test(string)) {
      jar.delete(pair.slice(0, separator));
    } else {
      jar.set(pair.slice(0, separator), pair.slice(separator + 1));
    }
  },
  configurable: true,
});

/** Wipes both stores, as a fresh browser profile would. */
const reset = () => {
  jar.clear();
  storage.clear();
  storageWritable = true;
};

test("stores and reads back values, parsing the integers", () => {
  reset();
  const store = new SettingsStore();

  store.set("docs", "css/javascript");
  store.set("size", 320);
  store.set("hideIntro", true);

  assert.equal(store.get("docs"), "css/javascript");
  assert.equal(store.get("size"), 320);
  assert.equal(store.get("hideIntro"), 1);
  assert.equal(store.get("missing"), undefined);
});

test("deletes a key written as false, and clears everything on reset", () => {
  reset();
  const store = new SettingsStore();
  store.set("docs", "css");
  store.set("hideIntro", true);

  store.set("hideIntro", false);
  assert.deepEqual(store.dump(), { docs: "css" });

  store.del("docs");
  assert.deepEqual(store.dump(), {});

  store.set("docs", "css");
  store.reset();
  assert.deepEqual(new SettingsStore().dump(), {});
});

test("sees what another store has written", () => {
  reset();
  const store = new SettingsStore();
  new SettingsStore().set("theme", "dark");

  assert.equal(store.get("theme"), "dark");
});

test("takes in the settings left in cookies, and expires them", () => {
  reset();
  // What is stored already wins over the cookie of the same name; the vendors'
  // own cookies aren't ours to take; the session-only one doesn't become
  // permanent; and a value keeps its spaces rather than its escapes.
  new SettingsStore().set("theme", "dark");
  document.cookie = "docs=css/javascript";
  document.cookie = "size=320";
  document.cookie = "layout=_max-width%20_sidebar-hidden";
  document.cookie = "theme=default";
  document.cookie = "analyticsConsentAsked=1";
  document.cookie = "_ga=GA1.2.3";

  const store = new SettingsStore();

  assert.deepEqual(store.dump(), {
    theme: "dark",
    docs: "css/javascript",
    size: "320",
    layout: "_max-width _sidebar-hidden",
  });
  assert.equal(store.get("size"), 320, "and integers still parse");
  assert.equal(document.cookie, "_ga=GA1.2.3");
});

test("reports a write that doesn't stick", () => {
  reset();
  const store = new SettingsStore();
  /** @type {unknown[]} */
  const blocked = [];
  const onBlocked = SettingsStore.onBlocked;
  SettingsStore.onBlocked = (key, value, actual) =>
    blocked.push([key, value, actual]);

  try {
    storageWritable = false;
    store.set("docs", "css/javascript");

    assert.deepEqual(blocked, [["docs", "css/javascript", undefined]]);
  } finally {
    SettingsStore.onBlocked = onBlocked;
  }
});

test("leaves the cookies alone when the migration can't be written", () => {
  reset();
  document.cookie = "docs=css/javascript";
  document.cookie = "theme=dark";

  storageWritable = false;
  new SettingsStore();

  assert.equal(document.cookie, "docs=css/javascript; theme=dark");

  // And a later boot, with storage writable again, still finds them.
  storageWritable = true;
  assert.deepEqual(new SettingsStore().dump(), {
    docs: "css/javascript",
    theme: "dark",
  });
  assert.equal(document.cookie, "");
});
