// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { Shortcuts } from "../../assets/javascripts/app/shortcuts.js";

/**
 * Feeds a key event to the dispatcher the way the document listener would.
 *
 * @param {Shortcuts} shortcuts
 * @param {number} which
 * @param {{ ctrlKey?: boolean, shiftKey?: boolean, altKey?: boolean }} modifiers
 * @returns {boolean} Whether the event was swallowed.
 */
const press = (shortcuts, which, modifiers) => {
  let defaultPrevented = false;
  shortcuts.onKeydown(
    /** @type {any} */ ({
      which,
      target: {},
      preventDefault: () => (defaultPrevented = true),
      ...modifiers,
    }),
  );
  return defaultPrevented;
};

// Ctrl/Cmd + Shift + arrow used to fall through the dispatcher entirely: the
// Ctrl branch only ran when Shift was up. It now scans the sidebar, which has
// to happen without disturbing the plain Ctrl chords next to it.
test("ctrl+shift+arrow scans the list, and the plain ctrl chords still jump", () => {
  const shortcuts = new Shortcuts();
  /** @type {string[]} */
  const triggered = [];
  for (const name of [
    "superShiftUp",
    "superShiftDown",
    "pageTop",
    "pageBottom",
  ]) {
    shortcuts.on(name, () => triggered.push(name));
  }

  assert.equal(press(shortcuts, 40, { ctrlKey: true, shiftKey: true }), true);
  assert.equal(press(shortcuts, 38, { ctrlKey: true, shiftKey: true }), true);
  assert.deepEqual(triggered, ["superShiftDown", "superShiftUp"]);

  press(shortcuts, 38, { ctrlKey: true });
  press(shortcuts, 40, { ctrlKey: true });
  assert.deepEqual(triggered.slice(2), ["pageTop", "pageBottom"]);
});

test("adding alt to the chord leaves the event alone", () => {
  const shortcuts = new Shortcuts();
  let triggered = false;
  shortcuts.on("superShiftDown", () => (triggered = true));

  assert.equal(
    press(shortcuts, 40, { ctrlKey: true, shiftKey: true, altKey: true }),
    false,
  );
  assert.equal(triggered, false);
});
