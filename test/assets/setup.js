// Loaded with `node --import` so that it runs before any asset module does.
//
// The assets are browser ES modules: they expect a handful of globals to exist
// when they evaluate, and one of them (app/config.js) is generated from ERB at
// build time and so isn't on disk. Both gaps are filled here.

import { registerHooks } from "node:module";

// The modules Sprockets renders from ERB at build time, and the fixtures that
// stand in for them under Node.
const GENERATED = {
  "app/config.js": "./fixtures/config.js",
  "docs.js": "./fixtures/docs.js",
  "templates/pages/news_tmpl.js": "./fixtures/news_tmpl.js",
  "templates/pages/root_tmpl.js": "./fixtures/root_tmpl.js",
};

const fixtures = new Map(
  Object.entries(GENERATED).map(([logical, fixture]) => [
    new URL(`../../assets/javascripts/${logical}`, import.meta.url).href,
    new URL(fixture, import.meta.url).href,
  ]),
);

registerHooks({
  resolve(specifier, context, nextResolve) {
    if (context.parentURL && specifier.startsWith(".")) {
      const fixture = fixtures.get(new URL(specifier, context.parentURL).href);
      if (fixture) return { url: fixture, shortCircuit: true };
    }
    return nextResolve(specifier, context);
  },
});

// Enough of a document for the class bodies that reference it as they
// evaluate; anything a test actually exercises, it stubs itself.
const noop = () => {};
const element = {
  className: "",
  classList: { add: noop, remove: noop, contains: () => false },
  style: {},
  addEventListener: noop,
  removeEventListener: noop,
  querySelector: () => null,
  querySelectorAll: () => [],
  getAttribute: () => null,
  setAttribute: noop,
  appendChild: noop,
};

// Some of these (navigator) are getter-only on the Node global, so they have
// to be defined rather than assigned.
const define = (name, value) =>
  Object.defineProperty(globalThis, name, {
    value,
    writable: true,
    configurable: true,
  });

define("document", {
  ...element,
  cookie: "",
  documentElement: element,
  body: element,
  createElement: () => ({ ...element }),
});
define("location", { hash: "", href: "", host: "", pathname: "/" });
define("navigator", { userAgent: "node", platform: "node" });
define("window", {
  ...globalThis,
  matchMedia: () => ({ media: "not all", matches: false, addListener: noop }),
});
