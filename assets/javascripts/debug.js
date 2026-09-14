// @ts-check

// Timing instrumentation, loaded alongside the app during development. Wraps
// the boot sequence and the searcher in console timers, and exposes
// `viewTree()` on `window` for inspecting which views are active.

//
// App
//

import { app } from "./app/app.js";
import { Searcher } from "./app/searcher.js";
/** @import { View } from "./views/view.js" */

const _init = app.init;
app.init = function () {
  console.time("Init");
  _init.call(app);
  console.timeEnd("Init");
  return console.time("Load");
};

const _start = app.start;
app.start = function () {
  console.timeEnd("Load");
  console.time("Start");
  _start.call(app, ...arguments);
  return console.timeEnd("Start");
};

//
// Searcher
//

// The search views import `Searcher` directly, so the timing subclass can't be
// swapped in under them any more; the timers are patched onto the prototype.

const _setup = Searcher.prototype.setup;
/** Opens the timing group for this query. */
Searcher.prototype.setup = function () {
  console.groupCollapsed(`Search: ${this.query}`);
  console.time("Total");
  return _setup.call(this);
};

const _match = Searcher.prototype.match;
/** Closes the previous matcher's timer before moving on. */
Searcher.prototype.match = function () {
  if (this.matcher) {
    console.timeEnd(this.matcher.name);
  }
  return _match.call(this);
};

const _setupMatcher = Searcher.prototype.setupMatcher;
/** Starts a timer for the matcher about to run. */
Searcher.prototype.setupMatcher = function () {
  console.time(this.matcher.name);
  return _setupMatcher.call(this);
};

const _end = Searcher.prototype.end;
/** Reports the result count and closes the group. */
Searcher.prototype.end = function () {
  console.log(`Results: ${this.totalResults}`);
  console.timeEnd("Total");
  console.groupEnd();
  return _end.call(this);
};

const _kill = Searcher.prototype.kill;
/** Closes the group when a search is abandoned part-way. */
Searcher.prototype.kill = function () {
  if (this.timeout) {
    if (this.matcher) {
      console.timeEnd(this.matcher.name);
    }
    console.groupEnd();
    console.timeEnd("Total");
    console.warn("Killed");
  }
  return _kill.call(this);
};

//
// View tree
//

/**
 * Prints the view tree under `view`, with each view coloured by whether it is
 * currently activated.
 *
 * @param {View} [view] Defaults to the root view.
 * @param {number} [level] The current depth, used for indentation.
 * @param {unknown[]} [visited] The views already printed, so that the shared ones
 *   aren't walked twice.
 */
function viewTree(view, level, visited) {
  if (view == null) {
    view = app.document;
  }
  if (level == null) {
    level = 0;
  }
  if (visited == null) {
    visited = [];
  }
  if (visited.includes(view)) {
    return;
  }
  visited.push(view);

  console.log(
    `%c ${Array(level + 1).join("  ")}${
      view.constructor.name
    }: ${!!view.activated}`,
    "color:" + ((view.activated && "green") || "red"),
  );

  for (var key of Object.keys(view || {})) {
    var value = view[key];
    if (key !== "view" && value) {
      if (typeof value === "object" && value.setupElement) {
        viewTree(value, level + 1, visited);
      } else if (value.constructor.toString().match(/Object\(\)/)) {
        for (var k of Object.keys(value || {})) {
          var v = value[k];
          if (v && typeof v === "object" && v.setupElement) {
            viewTree(v, level + 1, visited);
          }
        }
      }
    }
  }
}

// Reachable from the console, where the module scope isn't.
window.viewTree = viewTree;
