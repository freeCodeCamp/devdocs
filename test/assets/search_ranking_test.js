// @ts-check

const assert = require("node:assert/strict");
const fs = require("node:fs");
const test = require("node:test");
const vm = require("node:vm");

const context = {
  app: {
    config: {
      max_results: 50,
      docs_aliases: { julia: "jl" },
    },
    collections: {},
    models: {},
  },
  $: {
    escapeRegexp: (string) => string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
  },
};

vm.createContext(context);

// The files are concatenated because top-level class declarations aren't
// shared between scripts run in the same context.
vm.runInContext(
  [
    "assets/javascripts/lib/events.js",
    "assets/javascripts/app/searcher.js",
    "assets/javascripts/models/model.js",
    "assets/javascripts/models/entry.js",
    "assets/javascripts/models/doc.js",
  ]
    .map((file) => fs.readFileSync(file, "utf8"))
    .join("\n"),
  context,
  { filename: "devdocs.js" },
);

const { app } = context;

app.collections.Entries = class Entries {
  each() {}
};
app.collections.Types = class Types {
  each() {}
};

// The docs are listed in the order of the manifest, latest version first.
const search = (query, name, versions) => {
  const entries = versions.map((version) =>
    new app.models.Doc({
      name,
      slug: `${name.toLowerCase()}~${version}`,
      version,
    }).toEntry(),
  );

  const searcher = new app.SynchronousSearcher();
  let results = [];
  searcher.on("results", (found) => (results = found));
  searcher.find(entries, "text", query);
  return [...results.map((entry) => entry.name)];
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
