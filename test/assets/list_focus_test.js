// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { app } from "../../assets/javascripts/app/app.js";
import { ListFocus } from "../../assets/javascripts/views/list/list_focus.js";

/**
 * Replaces a global the modules read directly. `location` is getter-only on
 * the Node global, so it has to be defined rather than assigned.
 *
 * @param {string} name
 * @param {unknown} value
 */
const define = (name, value) =>
  Object.defineProperty(globalThis, name, {
    value,
    writable: true,
    configurable: true,
  });

/** Enough of an element for the list walk, the class juggling and `$.trigger`. */
class FakeElement {
  /**
   * @param {string} tagName
   * @param {Record<string, string>} [attrs]
   */
  constructor(tagName, attrs = {}) {
    this.tagName = tagName;
    this.attrs = attrs;
    this.className = "";
    /** @type {FakeElement[]} */
    this.childNodes = [];
    /** @type {FakeElement | null} */
    this.parentNode = null;
    /** The types dispatched on this element, in order. */
    this.dispatched = /** @type {string[]} */ ([]);

    /** @type {Set<string>} */
    const classes = new Set();
    this.classList = {
      /** @param {string} name */
      add: (name) => {
        classes.add(name);
        this.className = [...classes].join(" ");
      },
      /** @param {string} name */
      remove: (name) => {
        classes.delete(name);
        this.className = [...classes].join(" ");
      },
      /** @param {string} name */
      contains: (name) => classes.has(name),
    };
  }

  /** @param {FakeElement[]} children */
  append(...children) {
    for (const child of children) {
      child.parentNode = this;
      this.childNodes.push(child);
    }
    return this;
  }

  get firstChild() {
    return this.childNodes[0] ?? null;
  }

  get lastChild() {
    return this.childNodes[this.childNodes.length - 1] ?? null;
  }

  get nextSibling() {
    const siblings = this.parentNode?.childNodes ?? [];
    return siblings[siblings.indexOf(this) + 1] ?? null;
  }

  get previousSibling() {
    const siblings = this.parentNode?.childNodes ?? [];
    return siblings[siblings.indexOf(this) - 1] ?? null;
  }

  /** @param {string} name */
  getAttribute(name) {
    return this.attrs[name] ?? null;
  }

  /** @param {Event} event */
  dispatchEvent(event) {
    this.dispatched.push(event.type);
    return true;
  }

  /** @param {string} name */
  getElementsByClassName(name) {
    return this.descendants().filter((el) => el.classList.contains(name));
  }

  /** @param {string} tag */
  getElementsByTagName(tag) {
    const wanted = tag.toUpperCase();
    return this.descendants().filter((el) => el.tagName === wanted);
  }

  /** @returns {FakeElement[]} */
  descendants() {
    return this.childNodes.flatMap((child) => [child, ...child.descendants()]);
  }
}

/** Builds a two-row list bound to a `ListFocus`, with the navigations it makes. */
const setup = () => {
  define("HTMLElement", FakeElement);
  // The focus moves on the next frame, so that a paginated list has rendered.
  define("requestAnimationFrame", (/** @type {() => void} */ fn) => fn());
  define("location", { pathname: "/", hash: "" });

  const rows = ["/css/display", "/css/flex"].map(
    (href) => new FakeElement("A", { href }),
  );
  const list = new FakeElement("DIV").append(...rows);

  /** @type {string[]} */
  const replaced = [];
  /** @type {string[]} */
  const shown = [];
  app.router = /** @type {any} */ ({
    replace: (/** @type {string} */ path) => replaced.push(path),
    show: (/** @type {string} */ path) => shown.push(path),
  });

  return {
    rows,
    replaced,
    shown,
    listFocus: new ListFocus(/** @type {any} */ (list)),
  };
};

// Scanning a list of results is only bearable if the back button survives it,
// so a preview replaces the current history entry rather than pushing one —
// which also means it can't go through a click, the way `enter` does.
test("scanning down renders the next row in place of the current history entry", () => {
  const { rows, replaced, shown, listFocus } = setup();
  listFocus.focus(/** @type {any} */ (rows[0]));

  listFocus.onSuperShiftDown();

  assert.equal(rows[1].classList.contains("focus"), true);
  assert.equal(rows[0].classList.contains("focus"), false);
  assert.deepEqual(replaced, ["/css/flex"]);
  assert.deepEqual(shown, []);
  assert.deepEqual(rows[1].dispatched, ["focus"], "the row is not clicked");
});

test("scanning up renders the previous row", () => {
  const { rows, replaced, listFocus } = setup();
  listFocus.focus(/** @type {any} */ (rows[1]));

  listFocus.onSuperShiftUp();

  assert.equal(rows[0].classList.contains("focus"), true);
  assert.deepEqual(replaced, ["/css/display"]);
});

test("scanning past the end of the list stays put", () => {
  const { rows, replaced, listFocus } = setup();
  listFocus.focus(/** @type {any} */ (rows[1]));

  listFocus.onSuperShiftDown();

  assert.equal(rows[1].classList.contains("focus"), true);
  assert.deepEqual(replaced, []);
});

test("the row already being read isn't navigated to again", () => {
  const { rows, replaced, listFocus } = setup();
  define("location", { pathname: "/css/flex", hash: "" });

  listFocus.preview(/** @type {any} */ (rows[1]));

  assert.equal(rows[1].classList.contains("focus"), true);
  assert.deepEqual(replaced, []);
});
