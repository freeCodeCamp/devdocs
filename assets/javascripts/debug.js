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

app.Searcher = class TimingSearcher extends app.Searcher {
  setup() {
    console.groupCollapsed(`Search: ${this.query}`);
    console.time("Total");
    return super.setup();
  }

  match() {
    if (this.matcher) {
      console.timeEnd(this.matcher.name);
    }
    return super.match();
  }

  setupMatcher() {
    console.time(this.matcher.name);
    return super.setupMatcher();
  }

  end() {
    console.log(`Results: ${this.totalResults}`);
    console.timeEnd("Total");
    console.groupEnd();
    return super.end();
  }

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
