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
