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
  document.cookie = "docs=css/javascript";
  document.cookie = "size=320";

  const store = new SettingsStore();

  assert.equal(store.get("docs"), "css/javascript");
  assert.equal(store.get("size"), 320);
  assert.equal(document.cookie, "", "the cookies should be gone");
});

test("decodes a cookie value rather than storing its escapes", () => {
  reset();
  document.cookie = "layout=_max-width%20_sidebar-hidden";

  assert.equal(
    new SettingsStore().get("layout"),
    "_max-width _sidebar-hidden",
  );
});

test("keeps the stored value when a cookie of the same name is left over", () => {
  reset();
  new SettingsStore().set("theme", "dark");
  document.cookie = "theme=default";

  assert.equal(new SettingsStore().get("theme"), "dark");
  assert.equal(document.cookie, "");
});

test("leaves the analytics vendors' own cookies alone", () => {
  reset();
  document.cookie = "_ga=GA1.2.3";

  const store = new SettingsStore();

  assert.deepEqual(store.dump(), {});
  assert.equal(document.cookie, "_ga=GA1.2.3");
});

test("drops the consent-asked cookie rather than making it permanent", () => {
  reset();
  document.cookie = "analyticsConsentAsked=1";
  document.cookie = "analyticsConsent=1";

  const store = new SettingsStore();

  assert.deepEqual(store.dump(), { analyticsConsent: "1" });
  assert.equal(document.cookie, "");
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
