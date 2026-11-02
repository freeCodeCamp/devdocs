// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { app } from "../../assets/javascripts/app/app.js";
import { searchEntries } from "../../assets/javascripts/lib/doc_search.js";
import { docMenuResults, docMenuTypes } from "../../assets/javascripts/templates/doc_menu_tmpl.js";
import { offlinePage } from "../../assets/javascripts/templates/pages/offline_tmpl.js";
import { settingsPage } from "../../assets/javascripts/templates/pages/settings_tmpl.js";

const entries = ["Array.prototype.map()", "Map", "WeakMap", "map", "Array", "mapping guide"].map(
  (name) => ({ name }),
);

test("a doc's entries are searched best match first", () => {
  assert.deepEqual(
    searchEntries(entries, "map").map((entry) => entry.name),
    ["Map", "map", "mapping guide", "WeakMap", "Array.prototype.map()"],
  );
  // Every word has to be in the name, in any order.
  assert.deepEqual(
    searchEntries(entries, "map array").map((entry) => entry.name),
    ["Array.prototype.map()"],
  );
  assert.deepEqual(searchEntries(entries, "  "), []);
  assert.equal(searchEntries(entries, "a", 2).length, 2);
});

// Pack docs' names come from whoever published the pack.
const doc = /** @type {any} */ ({ fullName: "Notes <b>2</b>" });
const fakeType = (name, count) => ({ name, count, fullPath: () => "/notes-guide/" });

test("the doc menu lists the doc's sections, escaped", () => {
  const html = docMenuTypes(doc, /** @type {any} */ ([fakeType("Guide <img src=x onerror=alert(1)>", 3)]));
  assert.ok(html.includes('href="/notes-guide/"'));
  assert.ok(html.includes("Guide &lt;img src=x onerror=alert(1)&gt;<small>3</small>"));
  assert.ok(!html.includes("<img"));
  // $.escape also escapes slashes.
  assert.ok(docMenuTypes(doc, []).includes("Notes &lt;b&gt;2&lt;&#x2F;b&gt; has no sections"));
});

test("the doc menu shows search results, or says there are none", () => {
  const html = docMenuResults(doc, /** @type {any} */ ([{ name: "a < b", fullPath: () => "/notes/a" }]));
  assert.ok(html.includes('<a href="/notes/a" class="_doc-menu-link" role="listitem">a &lt; b</a>'));
  assert.ok(docMenuResults(doc, []).includes("Nothing in Notes &lt;b&gt;2&lt;&#x2F;b&gt; matches"));
});

/** @param {Record<string, unknown>} [extra] */
const preferences = (extra) =>
  settingsPage({
    docPacks: [{ url: "https://example.com/pack/", name: "Team <i>notes</i>", count: 2 }],
    docPackGuideUrl: "https://example.com/guide",
    ...extra,
  });

test("the doc packs section is at the bottom of Preferences, collapsed", () => {
  const html = preferences();
  const section = html.indexOf('id="doc-packs"');
  assert.ok(section > html.indexOf("Custom CSS:"), "after the last other section");
  assert.ok(section < html.indexOf('data-action="export"'), "before Export and Import");
  assert.match(html, /<details class="_settings-inputs _doc-packs">/);
  assert.match(html, /Show doc packs <small>\(1 added\)<\/small>/);

  assert.match(preferences({ docPacksOpen: true }), /<details class="_settings-inputs _doc-packs" open>/);
  assert.match(preferences({ docPacks: [] }), /<summary class="_doc-packs-summary">Add documentation by link<\/summary>/);
});

test("removing a pack asks in the page first", () => {
  const html = preferences();
  assert.match(html, /<div class="_doc-pack-confirm" role="alertdialog" aria-label="Confirm removal" hidden>/);
  assert.ok(html.includes("Remove <strong>Team &lt;i&gt;notes&lt;&#x2F;i&gt;</strong> and its docs from DevDocs?"));
  // Escaped in the attribute; getAttribute gives the address back as it was.
  assert.ok(html.includes('data-action="confirmRemovePack" data-url="https:&#x2F;&#x2F;example.com&#x2F;pack&#x2F;"'));
  // The first Remove only opens the box.
  assert.ok(html.includes('<button type="button" class="_btn-link" data-action="removePack">Remove</button>'));
});

test("the offline page has a yellow box leading to adding docs by link", () => {
  const settings = app.settings;
  app.settings = /** @type {any} */ ({ get: () => false });
  try {
    const html = offlinePage("", false, false);
    assert.match(
      html,
      /<p class="_note _offline-add-docs">[^]*<a href="\/settings#doc-packs">Add documentation by link<\/a>/,
    );
  } finally {
    app.settings = settings;
  }
});
