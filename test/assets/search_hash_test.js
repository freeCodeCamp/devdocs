// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { app } from "../../assets/javascripts/app/app.js";
import { $ } from "../../assets/javascripts/lib/util.js";
import { Search } from "../../assets/javascripts/views/search/search.js";
import { SearchScope } from "../../assets/javascripts/views/search/search_scope.js";

// The views are built through `Object.create` rather than constructed: the
// base View constructor resolves its selectors against a real document, and
// the methods under test only read statics and globals.
const build = (Klass) => Object.create(Klass.prototype);

test("URL search hash preserves plus signs in a scoped C++ query", () => {
  location.hash = "#q=c++%20std::min";

  const scope = build(SearchScope);
  let replacedHash;
  app.router = /** @type {any} */ ({
    replaceHash: (hash) => {
      replacedHash = hash;
    },
  });

  assert.equal(scope.getHashValue(), "c++");
  assert.equal(scope.extractHashValue(), "c++");
  assert.equal(replacedHash, "#q=std::min");
});

test("URL search hash preserves encoded literal plus signs in the query", () => {
  location.hash = "#q=operator%2B";

  assert.equal(build(Search).getHashValue(), "operator+");
});

test("scoped external search includes the documentation name", () => {
  let popupUrl;
  $.popup = (url) => {
    popupUrl = url;
  };

  const search = build(Search);
  search.value = "status";
  search.scope = { name: () => "Git" };
  search.reset = () => {};

  search.externalSearch("https://www.google.com/search?q=");

  assert.equal(popupUrl, "https://www.google.com/search?q=Git%20status");
});
