// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { app } from "../../assets/javascripts/app/app.js";
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

test.beforeEach(() => {
  requests.length = 0;
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

test("an index left in localStorage is taken in on the read that wants it", () => {
  const stored = { css: [42, INDEX], html: [7, INDEX] };
  app.localStorage = /** @type {any} */ ({
    get: (/** @type {string} */ key) => stored[key],
    del: (/** @type {string} */ key) => delete stored[key],
  });

  const db = new DB();
  /** @type {unknown[]} */
  const puts = [];
  db.indexes = (mode, fn) =>
    fn(/** @type {any} */ ({ put: (value, key) => puts.push([key, value]) }));

  assert.equal(db.importIndex(newDoc(), 42), INDEX, "the doc's own index");
  assert.deepEqual(puts, [["css", [42, INDEX]]], "moved into the database");
  assert.deepEqual(stored, { html: [7, INDEX] }, "and out of localStorage");
});

test("an index left over from an earlier build is dropped, not taken in", () => {
  const stored = { css: [7, INDEX] };
  app.localStorage = /** @type {any} */ ({
    get: (/** @type {string} */ key) => stored[key],
    del: (/** @type {string} */ key) => delete stored[key],
  });

  const db = new DB();
  db.indexes = () => assert.fail("nothing should be stored");

  assert.equal(db.importIndex(newDoc(), 42), undefined);
  assert.deepEqual(stored, {});
});
