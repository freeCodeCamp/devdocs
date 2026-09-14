// @ts-check

// Timing instrumentation, loaded in place of the app's own bundle during
// development. Wraps the boot sequence and the searcher in console timers, and
// adds `viewTree()` for inspecting which views are active.

//
// App
//

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

/** The searcher, with each matcher's pass timed. */
app.Searcher = class TimingSearcher extends app.Searcher {
  /** Opens the timing group for this query. */
  setup() {
    console.groupCollapsed(`Search: ${this.query}`);
    console.time("Total");
    return super.setup();
  }

  /** Closes the previous matcher's timer before moving on. */
  match() {
    if (this.matcher) {
      console.timeEnd(this.matcher.name);
    }
    return super.match();
  }

  /** Starts a timer for the matcher about to run. */
  setupMatcher() {
    console.time(this.matcher.name);
    return super.setupMatcher();
  }

  /** Reports the result count and closes the group. */
  end() {
    console.log(`Results: ${this.totalResults}`);
    console.timeEnd("Total");
    console.groupEnd();
    return super.end();
  }

  /** Closes the group when a search is abandoned part-way. */
  kill() {
    if (this.timeout) {
      if (this.matcher) {
        console.timeEnd(this.matcher.name);
      }
      console.groupEnd();
      console.timeEnd("Total");
      console.warn("Killed");
    }
    return super.kill();
  }
};

//
// View tree
//

/**
 * Prints the view tree under `view`, with each view coloured by whether it is
 * currently activated.
 *
 * @param {any} [view] Defaults to the root view.
 * @param {number} [level] The current depth, used for indentation.
 * @param {any[]} [visited] The views already printed, so that the shared ones
 *   aren't walked twice.
 */
this.viewTree = function (view, level, visited) {
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
        this.viewTree(value, level + 1, visited);
      } else if (value.constructor.toString().match(/Object\(\)/)) {
        for (var k of Object.keys(value || {})) {
          var v = value[k];
          if (v && typeof v === "object" && v.setupElement) {
            this.viewTree(v, level + 1, visited);
          }
        }
      }
    }
  }
};
