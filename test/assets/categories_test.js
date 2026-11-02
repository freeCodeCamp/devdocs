// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import {
  CATEGORIES,
  categoryOf,
  findCategory,
  groupByCategory,
} from "../../assets/javascripts/app/categories.js";
import { packDocs, readManifest } from "../../assets/javascripts/lib/doc_packs.js";
import { Doc } from "../../assets/javascripts/models/doc.js";

test("built-in docs are sorted into categories, whatever their version", () => {
  assert.equal(categoryOf({ slug: "python~3.12" }), "languages");
  assert.equal(categoryOf({ slug: "css" }), "web");
  assert.equal(categoryOf({ slug: "vue~3" }), "frameworks");
  assert.equal(categoryOf({ slug: "lodash~4" }), "libraries");
  assert.equal(categoryOf({ slug: "jest" }), "testing");
  assert.equal(categoryOf({ slug: "git" }), "tools");
  assert.equal(categoryOf({ slug: "postgresql~16" }), "databases");
  assert.equal(categoryOf({ slug: "pytorch~2" }), "ai");
  assert.equal(categoryOf({ slug: "nginx" }), "services");
  assert.equal(categoryOf({ slug: "not_a_doc" }), "other");
  assert.equal(new Doc({ name: "Git", slug: "git" }).category, "tools");
});

test("a pack doc names its own category, or is Other", () => {
  const pack = readManifest(
    [
      { name: "Claude", slug: "claude", category: "ai" },
      { name: "Git notes", slug: "git" },
      { name: "Odd", slug: "odd", category: "<b>" },
    ],
    "https://example.com/",
  );
  const docs = packDocs(pack).map((attributes) => new Doc(attributes));
  assert.deepEqual(
    docs.map((doc) => doc.category),
    ["ai", "other", "other"],
    "a pack's git doc isn't sorted with the built-in Git",
  );
});

test("a category can be named in full, by its id or a short form", () => {
  assert.equal(findCategory("Databases")?.id, "databases");
  assert.equal(findCategory(" db ")?.id, "databases");
  assert.equal(findCategory("AI")?.id, "ai");
  assert.equal(findCategory("frameworks & platforms")?.id, "frameworks");
  assert.equal(findCategory("css"), undefined);
  assert.equal(findCategory(""), undefined);
});

test("no name stands for two categories", () => {
  /** @type {Map<string, string>} */
  const owner = new Map();
  for (const category of CATEGORIES) {
    for (const name of new Set([category.id, category.name.toLowerCase(), ...category.aliases])) {
      assert.ok(!owner.has(name), `"${name}" is used by ${owner.get(name)} and ${category.id}`);
      owner.set(name, category.id);
    }
  }
});

test("docs are grouped in the categories' order, keeping their own order", () => {
  const docs = [
    { name: "Vue", category: "frameworks" },
    { name: "CSS", category: "web" },
    { name: "Angular", category: "frameworks" },
    { name: "Python", category: "languages" },
  ];
  assert.deepEqual(
    groupByCategory(docs).map(({ category, docs }) => [category.id, docs.map((doc) => doc.name)]),
    [
      ["languages", ["Python"]],
      ["web", ["CSS"]],
      ["frameworks", ["Vue", "Angular"]],
    ],
  );
});
