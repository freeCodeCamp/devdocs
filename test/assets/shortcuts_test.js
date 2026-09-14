// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { Shortcuts } from "../../assets/javascripts/app/shortcuts.js";

/**
 * Feeds a key event to the dispatcher the way the document listener would.
 *
 * @param {Shortcuts} shortcuts
 * @param {string} key
 * @param {{ code?: string, ctrlKey?: boolean, shiftKey?: boolean, altKey?: boolean }} modifiers
 * @returns {boolean} Whether the event was swallowed.
 */
const press = (shortcuts, key, modifiers) => {
  let defaultPrevented = false;
  shortcuts.onKeydown(
    /** @type {any} */ ({
      key,
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

  const chord = { ctrlKey: true, shiftKey: true };
  assert.equal(press(shortcuts, "ArrowDown", chord), true);
  assert.equal(press(shortcuts, "ArrowUp", chord), true);
  assert.deepEqual(triggered, ["superShiftDown", "superShiftUp"]);

  press(shortcuts, "ArrowUp", { ctrlKey: true });
  press(shortcuts, "ArrowDown", { ctrlKey: true });
  assert.deepEqual(triggered.slice(2), ["pageTop", "pageBottom"]);
});

test("adding alt to the chord leaves the event alone", () => {
  const shortcuts = new Shortcuts();
  let triggered = false;
  shortcuts.on("superShiftDown", () => (triggered = true));

  assert.equal(
    press(shortcuts, "ArrowDown", {
      ctrlKey: true,
      shiftKey: true,
      altKey: true,
    }),
    false,
  );
  assert.equal(triggered, false);
});

// Alt rewrites the character a letter key produces, so `key` reads "ß" for
// alt + s on a Mac and none of the alt chords would fire.
test("the alt chords go by the key's position, not the character it types", () => {
  const shortcuts = new Shortcuts();
  let triggered = false;
  shortcuts.on("altS", () => (triggered = true));

  assert.equal(press(shortcuts, "ß", { code: "KeyS", altKey: true }), true);
  assert.equal(triggered, true);
});

test("typing a letter or a digit starts a search, whatever the script", () => {
  const shortcuts = new Shortcuts();
  let typed = 0;
  shortcuts.on("typing", () => typed++);

  for (const key of ["a", "Z", "7", "д"]) {
    assert.equal(press(shortcuts, key, {}), false, key);
  }
  assert.equal(typed, 4);

  press(shortcuts, "Shift", {});
  press(shortcuts, "F5", {});
  assert.equal(typed, 4);
});
