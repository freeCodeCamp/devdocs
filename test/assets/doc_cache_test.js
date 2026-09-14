// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { app } from "../../assets/javascripts/app/app.js";
import { LocalStorageStore } from "../../assets/javascripts/lib/local_storage_store.js";
import { DB } from "../../assets/javascripts/app/db.js";
import { Doc } from "../../assets/javascripts/models/doc.js";

// ajax() goes through XMLHttpRequest, so a fake one is enough to see whether a
// load reached the network, and to answer it.
/** @type {any[]} */
const requests = [];

Object.defineProperty(globalThis, "XMLHttpRequest", {
  value: class {
    open(/** @type {string} */ type, /** @type {string} */ url) {
      this.url = url;
      requests.push(this);
    }
    setRequestHeader() {}
    send() {}
    abort() {}
    /** Answers the request the way ajax() reads a response back. */
    respond(/** @type {unknown} */ index) {
      this.readyState = 4;
      this.status = 200;
      this.responseText = JSON.stringify(index);
      /** @type {any} */ (this).onreadystatechange();
    }
  },
  writable: true,
  configurable: true,
});

/** The index a doc loads, kept minimal: the shape is all Doc#reset touches. */
const INDEX = { entries: [], types: [] };

/** Stands in for the database, with one doc's index cached in it. */
const stubStore = (cached) => {
  /** @type {{ reads: string[], written: unknown[] }} */
  const calls = { reads: [], written: [] };
  app.db = /** @type {any} */ ({
    loadIndex(doc, mtime, fn) {
      calls.reads.push(`${doc.slug}@${mtime}`);
      // Asynchronous, as the real one is.
      setTimeout(() => fn(cached), 0);
    },
    storeIndex(doc, mtime, index) {
      calls.written.push([doc.slug, mtime, index]);
    },
    deleteIndex(doc) {
      calls.written.push([doc.slug, null]);
    },
  });
  return calls;
};

const newDoc = () => new Doc({ name: "CSS", slug: "css", mtime: 42 });

test("a cached index is used instead of the network", async () => {
  requests.length = 0;
  const calls = stubStore(INDEX);
  const doc = newDoc();

  await new Promise((resolve) =>
    doc.load(() => resolve(undefined), () => assert.fail("errored"), {
      readCache: true,
    }),
  );

  assert.deepEqual(calls.reads, ["css@42"], "the store should be asked once");
  assert.equal(requests.length, 0, "nothing should have been fetched");
  assert.ok(doc.entries, "the doc should have been reset from the cache");
});

test("a miss falls through to the network, and stores what it fetched", async () => {
  requests.length = 0;
  const calls = stubStore(undefined);
  const doc = newDoc();

  const loaded = new Promise((resolve) =>
    doc.load(() => resolve(undefined), () => assert.fail("errored"), {
      readCache: true,
      writeCache: true,
    }),
  );

  // The store answers on a timer, so the request is only made after it has.
  await new Promise((resolve) => setTimeout(resolve, 0));
  assert.equal(requests.length, 1, "the index should have been fetched");
  assert.match(requests[0].url, /\/css\/index\.json\?42$/);

  requests[0].respond(INDEX);
  await loaded;

  assert.deepEqual(calls.written, [["css", 42, INDEX]]);
});

test("the cache is left alone when the caller doesn't ask for it", async () => {
  requests.length = 0;
  const calls = stubStore(INDEX);
  const doc = newDoc();

  const loaded = new Promise((resolve) =>
    doc.load(() => resolve(undefined), () => assert.fail("errored")),
  );

  assert.deepEqual(calls.reads, [], "the store shouldn't have been read");
  assert.equal(requests.length, 1);

  requests[0].respond(INDEX);
  await loaded;

  assert.deepEqual(calls.written, [], "and nothing should have been written");
});

test("a doc drops its cached index when it is cleared", () => {
  const calls = stubStore(INDEX);
  newDoc().clearCache();
  assert.deepEqual(calls.written, [["css", null]]);
});

// Items are own properties of a real Storage, and its methods live on the
// prototype, which is what makes Object.keys() return the keys and nothing
// else.
class FakeStorage {
  constructor(/** @type {Record<string, string>} */ entries) {
    Object.assign(this, entries);
  }
  getItem(/** @type {string} */ key) {
    return Object.prototype.hasOwnProperty.call(this, key) ? this[key] : null;
  }
  setItem(/** @type {string} */ key, /** @type {string} */ value) {
    this[key] = String(value);
  }
  removeItem(/** @type {string} */ key) {
    delete this[key];
  }
  clear() {
    for (const key of Object.keys(this)) delete this[key];
  }
}

test("the indexes an older app cached in localStorage are taken in", () => {
  const stored = new FakeStorage({
    settings: '{"docs":"css"}',
    "override-mobile-detect": "true",
    css: '[42,{"entries":[]}]',
    html: '[7,{"entries":[]}]',
    junk: '"not an index"',
  });

  Object.defineProperty(globalThis, "localStorage", {
    value: stored,
    writable: true,
    configurable: true,
  });

  app.localStorage = new LocalStorageStore();
  const db = new DB();
  /** @type {unknown[]} */
  const puts = [];
  db.db = (fn) => fn(/** @type {any} */ ({}));
  db.indexesStore = () =>
    /** @type {any} */ ({ put: (value, key) => puts.push([key, value]) });

  db.migrateIndexes();

  assert.deepEqual(puts, [
    ["css", [42, { entries: [] }]],
    ["html", [7, { entries: [] }]],
  ]);
  assert.deepEqual(
    Object.keys(stored),
    ["settings", "override-mobile-detect"],
    "everything else should have been cleared out",
  );
});
