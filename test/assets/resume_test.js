// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { Resume } from "../../assets/javascripts/app/resume.js";

/** A stand-in for LocalStorageStore. */
const memoryStore = () => {
  const data = new Map();
  return /** @type {any} */ ({
    get: (key) => data.get(key),
    set: (key, value) => {
      data.set(key, JSON.parse(JSON.stringify(value)));
      return true;
    },
  });
};

const home = { pathname: "/", search: "", hash: "" };
const enabled = (slug) => ["css", "javascript"].includes(slug);

test("the page read last, and its scroll position, are reopened from the home page", () => {
  const resume = new Resume(memoryStore());
  assert.equal(resume.target(home, enabled), null, "nothing read yet");

  resume.remember("/css/flex#syntax");
  resume.rememberScroll(812.6);
  assert.deepEqual(resume.target(home, enabled), { path: "/css/flex#syntax", scrollTop: 813 });

  resume.remember("/css/flex#syntax");
  assert.equal(resume.last()?.scrollTop, 813, "reopening the same page keeps its position");

  resume.remember("/javascript/global_objects/array");
  assert.equal(resume.last()?.scrollTop, 0, "another page starts at its top");
});

test("a link to a page, or a search, isn't overridden", () => {
  const resume = new Resume(memoryStore());
  resume.remember("/css/flex");
  assert.equal(resume.target({ ...home, pathname: "/javascript/" }, enabled), null);
  assert.equal(resume.target({ ...home, hash: "#q=map" }, enabled), null);
  assert.equal(resume.target({ ...home, search: "?q=map" }, enabled), null);
});

test("a page of a doc that's no longer enabled isn't reopened", () => {
  const resume = new Resume(memoryStore());
  resume.remember("/python~3.12/library/os");
  assert.equal(resume.target(home, enabled), null);
  resume.remember("/css-properties/");
  assert.equal(resume.target(home, enabled)?.path, "/css-properties/", "a type page");
});

test("stored values that aren't a page within DevDocs are ignored", () => {
  const store = memoryStore();
  const resume = new Resume(store);
  for (const value of [null, "x", { path: 5 }, { path: "https://evil.example/" }, { path: "//evil.example/css/" }]) {
    store.set(Resume.STORAGE_KEY, value);
    assert.equal(resume.last(), null, JSON.stringify(value));
  }
  store.set(Resume.STORAGE_KEY, { path: "/css/", scrollTop: "lots" });
  assert.deepEqual(resume.last(), { path: "/css/", scrollTop: 0 });
});
