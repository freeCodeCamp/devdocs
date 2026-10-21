// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import {
  Searcher,
  SynchronousSearcher,
} from "../../assets/javascripts/app/searcher.js";
import { Entry } from "../../assets/javascripts/models/entry.js";

/**
 * @param {string} query
 * @param {string[]} names
 */
const search = (query, names) => {
  const entries = names.map((name) => new Entry({ name }));
  const searcher = new SynchronousSearcher();
  /** @type {Entry[]} */
  let results = [];
  searcher.on("results", (found) => (results = /** @type {Entry[]} */ (found)));
  searcher.find(entries, "text", query);
  return results.map((entry) => entry.name);
};

test("standalone symbolic names survive separator normalization", () => {
  // These symbols also act as separators in compound names.
  for (const name of ["->", "#", "::", ":-"]) {
    assert.deepEqual(search(name, ["unrelated", name]), [name]);
    assert.deepEqual(search(`  ${name}  `, [name]), [name]);
    assert.deepEqual(search(`${name}()`, [name]), [name]);
    assert.deepEqual(search(`${name} (macro)`, [name]), [name]);
  }
});

test("Clojure operators keep exact matches first", () => {
  const names = ["some->>", "cond->>", "->>", "->", "-'", "-", "+'", "+"];
  assert.deepEqual(search("->", names), ["->"]);
  assert.deepEqual(search("->>", names), ["->>", "some->>", "cond->>"]);
  assert.deepEqual(search("-", names), ["-", "->", "-'"]);
  assert.deepEqual(search("+", names), ["+", "+'"]);
});

test("member separators keep equivalent queries and suffix ranking", () => {
  const names = [
    "Other#method", "Class->method", "Class::method", "Class#method.extra",
  ];
  const expected = ["Class->method", "Class::method", "Class#method.extra"];
  for (const query of ["Class->method", "Class::method", "Class.method"]) {
    assert.deepEqual(search(query, names), expected);
  }
  assert.deepEqual(search("method", names), [
    "Other#method", "Class->method", "Class::method", "Class#method.extra",
  ]);
  assert.deepEqual(search("Class->", names), expected);
});

test("ordinary normalization retains namespaces, decoration and separators", () => {
  const equivalent = [
    "Class#method", "Class::method", "Class:-method", "Class->method",
    "Class$method", "Class-method", "Class:method", "Class / method",
    "Class - method", "Class & method", "Class: method", "Class method",
    "Class..method()", "Class.method (method)", "Class.method event",
  ];
  for (const name of equivalent) {
    assert.equal(Searcher.normalizeString(name), "class.method");
  }
  assert.deepEqual(search("clojure.core", ["clojure.core", "clojure.core.protocols"]), [
    "clojure.core", "clojure.core.protocols",
  ]);
  assert.equal(Searcher.normalizeQuery("Class-"), "class.");
  assert.equal(Searcher.normalizeQuery("Class:"), "class.");
});

test("empty and dot-only queries stay suppressed", () => {
  for (const query of ["", " ", ".", "..", "..."]) {
    assert.deepEqual(search(query, [".", "..", "Class.method"]), []);
  }
});

test("fuzzy matching and exact matches keep their ordering", () => {
  assert.deepEqual(search("map", ["my-map", "map", "make-apple-pie"]), [
    "map", "my-map", "make-apple-pie",
  ]);
});
