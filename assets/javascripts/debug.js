// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS207: Consider shorter variations of null checks
 * DS208: Avoid top-level this
 * DS209: Avoid top-level return
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
if (
  !(typeof console !== "undefined" && console !== null
    ? console.time
    : undefined) ||
  !console.groupCollapsed
) {
  return;
}

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

const _super = app.Searcher;
const _proto = app.Searcher.prototype;

app.Searcher = function () {
  _super.apply(this, arguments);

  const _setup = this.setup.bind(this);
  this.setup = function () {
    console.groupCollapsed(`Search: ${this.query}`);
    console.time("Total");
    return _setup();
  };

  const _match = this.match.bind(this);
  this.match = () => {
    if (this.matcher) {
      console.timeEnd(this.matcher.name);
    }
    return _match();
  };

  const _setupMatcher = this.setupMatcher.bind(this);
  this.setupMatcher = function () {
    console.time(this.matcher.name);
    return _setupMatcher();
  };

  const _end = this.end.bind(this);
  this.end = function () {
    console.log(`Results: ${this.totalResults}`);
    console.timeEnd("Total");
    console.groupEnd();
    return _end();
  };

  const _kill = this.kill.bind(this);
  this.kill = function () {
    if (this.timeout) {
      if (this.matcher) {
        console.timeEnd(this.matcher.name);
      }
      console.groupEnd();
      console.timeEnd("Total");
      console.warn("Killed");
    }
    return _kill();
  };
};

$.extend(app.Searcher, _super);
_proto.constructor = app.Searcher;
app.Searcher.prototype = _proto;

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
  if (visited.indexOf(view) >= 0) {
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
