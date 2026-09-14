// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { config } from "../../assets/javascripts/app/config.js";
import { SynchronousSearcher } from "../../assets/javascripts/app/searcher.js";
import { Doc } from "../../assets/javascripts/models/doc.js";

config.docs_aliases = { julia: "jl" };

// The docs are listed in the order of the manifest, latest version first.
const search = (query, name, versions) => {
  const entries = versions.map((version) =>
    new Doc({
      name,
      slug: `${name.toLowerCase()}~${version}`,
      version,
    }).toEntry(),
  );

  const searcher = new SynchronousSearcher();
  /** @type {any[]} */
  let results = [];
  searcher.on("results", (found) => (results = /** @type {any[]} */ (found)));
  searcher.find(entries, "text", query);
  return results.map((entry) => entry.name);
};

const JULIA = ["1.13", "1.12", "1.11", "1.10", "1.9", "1.8"];

test("searching for a doc lists its versions from the latest one", () => {
  assert.deepEqual(
    search("julia", "Julia", JULIA),
    JULIA.map((version) => `Julia ${version}`),
  );
  assert.deepEqual(search("cmake", "CMake", ["3.31", "3.9"]), [
    "CMake 3.31",
    "CMake 3.9",
  ]);
});

test("the alias of a doc matches all of its versions", () => {
  assert.deepEqual(
    search("jl", "Julia", JULIA),
    JULIA.map((version) => `Julia ${version}`),
  );
});
