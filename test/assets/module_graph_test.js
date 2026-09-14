// @ts-check

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

// The modules import each other in cycles (a view reaches the app singleton,
// the app builds the views), which ES modules allow but which breaks if
// anything reads an imported binding while its module is still evaluating —
// a `static` field initialiser, typically. That fails only at load time, so
// evaluate the whole graph in the order the browser would.
test("the whole module graph evaluates without a cycle error", async () => {
  // application.js imports app/app.js first, so importing it here puts the
  // graph in the same order the page does, and lets the boot be stubbed out
  // before application.js calls it.
  const { app } = await import("../../assets/javascripts/app/app.js");

  let booted = false;
  app.init = () => {
    booted = true;
  };

  await import("../../assets/javascripts/application.js");
  assert.equal(booted, true, "application.js should boot the app");
});

test("the debug module patches the app without evaluating it twice", async () => {
  const { app } = await import("../../assets/javascripts/app/app.js");
  const init = app.init;

  await import("../../assets/javascripts/debug.js");
  assert.notEqual(app.init, init, "debug.js should wrap app.init");
});

// The modules rendered from ERB are replaced by fixtures under Node, so the
// graph test above evaluates stand-ins rather than the real thing. These are
// dependencies of the app singleton (templates/base.js pulls the templates
// in), which means they evaluate *before* `app` is initialised — touching it
// there throws a ReferenceError in the browser, before boot, and no fixture
// would show it. Keep them leaves.
test("the generated modules stay out of the app's initialisation cycle", () => {
  const generated = [
    "app/config.js.erb",
    "templates/pages/news_tmpl.js.erb",
    "templates/pages/root_tmpl.js.erb",
  ];

  for (const file of generated) {
    const source = readFileSync(
      new URL(`../../assets/javascripts/${file}`, import.meta.url),
      "utf8",
    );
    assert.doesNotMatch(
      source,
      /^import\b.*app\/app\.js/m,
      `${file} must not import the app singleton`,
    );
    assert.doesNotMatch(
      source,
      /^app\./m,
      `${file} must not assign onto the app singleton`,
    );
  }
});
