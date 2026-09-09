const assert = require("node:assert/strict");
const fs = require("node:fs");
const test = require("node:test");
const vm = require("node:vm");

const context = {
  app: {
    config: { search_param: "q" },
    router: { replaceHash: () => {} },
    views: {},
    View: class {},
  },
  location: { hash: "" },
  $: {
    urlDecodeFragment: decodeURIComponent,
  },
};

vm.createContext(context);

for (const file of [
  "assets/javascripts/views/search/search_scope.js",
  "assets/javascripts/views/search/search.js",
]) {
  vm.runInContext(fs.readFileSync(file, "utf8"), context, {
    filename: file,
  });
}

test("URL search hash preserves plus signs in a scoped C++ query", () => {
  context.location.hash = "#q=c++%20std::min";

  const scope = new context.app.views.SearchScope();
  let replacedHash;
  context.app.router.replaceHash = (hash) => {
    replacedHash = hash;
  };

  assert.equal(scope.getHashValue(), "c++");
  assert.equal(scope.extractHashValue(), "c++");
  assert.equal(replacedHash, "#q=std::min");
});

test("URL search hash preserves encoded literal plus signs in the query", () => {
  context.location.hash = "#q=operator%2B";

  const search = new context.app.views.Search();

  assert.equal(search.getHashValue(), "operator+");
});

test("search scope shows a hint for the matching enabled documentation", () => {
  const scope = Object.create(context.app.views.SearchScope.prototype);
  const docs = [{ fullName: "Ruby 3" }];
  let searchArgs;

  context.app.docs = { all: () => docs };
  context.app.isMobile = () => false;
  context.app.isSingleDoc = () => false;

  scope.input = {
    value: "ruby",
    selectionStart: 4,
    style: {},
  };
  scope.hint = { offsetWidth: 140, style: {} };
  scope.hintKey = {};
  scope.hintDoc = {};
  scope.hintSearcher = {
    find: (...args) => {
      searchArgs = args;
    },
  };

  scope.onInput();
  assert.deepEqual(searchArgs, [docs, "text", "ruby"]);

  scope.onHintResults(docs);
  assert.equal(scope.hintKey.textContent, "Tab");
  assert.equal(scope.hintDoc.textContent, "Ruby 3");
  assert.equal(scope.hint.style.display, "block");
  assert.equal(scope.input.style.paddingRight, "168px");

  scope.doc = docs[0];
  scope.onInput();
  assert.equal(scope.hint.style.display, "none");
  assert.equal(scope.hintDoc.textContent, "");
  assert.equal(scope.input.style.paddingRight, "");
});
