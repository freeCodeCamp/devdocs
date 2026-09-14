// @ts-check

import { app } from "./app.js";
import { Events } from "../lib/events.js";
import { $ } from "../lib/util.js";

/**
 * A key event whose target is read loosely: the handlers check for form-field
 * properties that only some elements have.
 *
 * @typedef {KeyboardEvent & { target: HTMLElement & Partial<HTMLInputElement> }} ShortcutEvent
 */

/** The keys the `arrowScroll` setting swaps with their shifted selves. */
const ARROW_KEYS = ["ArrowLeft", "ArrowUp", "ArrowRight", "ArrowDown"];

/** A key that types a letter or a digit, in any script. */
const ALPHANUMERIC_KEY = /^[\p{L}\p{N}]$/u;

/** A key that types a letter, in any script. */
const LETTER_KEY = /^\p{L}$/u;

/**
 * Translates key events into shortcut events.
 *
 * Handlers return `false` to swallow the event; anything else lets it through.
 */
export class Shortcuts extends Events {
  /** Starts listening for key events. */
  constructor() {
    super();
    this.onKeydown = this.onKeydown.bind(this);
    this.onKeypress = this.onKeypress.bind(this);
    this.isMac = $.isMac();
    this.start();
  }

  /** Begins listening for key events. */
  start() {
    $.on(document, "keydown", this.onKeydown);
    $.on(document, "keypress", this.onKeypress);
  }

  /** Stops listening for key events. */
  stop() {
    $.off(document, "keydown", this.onKeydown);
    $.off(document, "keypress", this.onKeypress);
  }

  /** @returns {boolean} Whether the arrow keys scroll rather than move the selection. */
  swapArrowKeysBehavior() {
    return !!app.settings.get("arrowScroll");
  }

  /** @returns {number} How far space scrolls, as a fraction of the viewport. */
  spaceScroll() {
    return app.settings.get("spaceScroll");
  }

  /** Shows the key-navigation tip, once. */
  showTip() {
    app.showTip("KeyNav");
    return (this.showTip = null);
  }

  /** @returns {number | string} How long after typing space stops scrolling, in seconds. */
  spaceTimeout() {
    return app.settings.get("spaceTimeout");
  }

  /** @param {ShortcutEvent} event */
  onKeydown(event) {
    const result = (() => {
      if (event.ctrlKey || event.metaKey) {
        if (!event.altKey) {
          if (event.shiftKey) {
            return this.handleKeydownSuperShiftEvent(event);
          } else {
            return this.handleKeydownSuperEvent(event);
          }
        }
      } else if (event.shiftKey) {
        if (!event.altKey) {
          return this.handleKeydownShiftEvent(event);
        }
      } else if (event.altKey) {
        return this.handleKeydownAltEvent(event);
      } else {
        return this.handleKeydownEvent(event);
      }
    })();

    if (result === false) {
      event.preventDefault();
    }
  }

  /** @param {ShortcutEvent} event */
  onKeypress(event) {
    if (event.key === "?" && document.activeElement.tagName === "INPUT") {
      return;
    }
    if (!event.ctrlKey && !event.metaKey) {
      const result = this.handleKeypressEvent(event);
      if (result === false) {
        event.preventDefault();
      }
    }
  }

  /**
   * @param {ShortcutEvent} event
   * @param {boolean} [_force]
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeydownEvent(event, _force) {
    if (
      !_force &&
      ARROW_KEYS.includes(event.key) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownAltEvent(event, true);
    }

    if (!event.target.form && ALPHANUMERIC_KEY.test(event.key)) {
      this.trigger("typing");
      return;
    }

    switch (event.key) {
      case "Backspace":
        if (!event.target.form) {
          return this.trigger("typing");
        }
        break;
      case "Enter":
        return this.trigger("enter");
      case "Escape":
        this.trigger("escape");
        return false;
      case " ":
        if (
          event.target.type === "search" &&
          this.spaceScroll() &&
          (!this.lastKeypress ||
            this.lastKeypress < Date.now() - Number(this.spaceTimeout()) * 1000)
        ) {
          this.trigger("pageDown");
          return false;
        }
        break;
      case "PageUp":
        return this.trigger("pageUp");
      case "PageDown":
        return this.trigger("pageDown");
      case "End":
        if (!event.target.form) {
          return this.trigger("pageBottom");
        }
        break;
      case "Home":
        if (!event.target.form) {
          return this.trigger("pageTop");
        }
        break;
      case "ArrowLeft":
        if (!event.target.value) {
          return this.trigger("left");
        }
        break;
      case "ArrowUp":
        this.trigger("up");
        if (typeof this.showTip === "function") {
          this.showTip();
        }
        return false;
      case "ArrowRight":
        if (!event.target.value) {
          return this.trigger("right");
        }
        break;
      case "ArrowDown":
        this.trigger("down");
        if (typeof this.showTip === "function") {
          this.showTip();
        }
        return false;
      case "/":
        if (!event.target.form) {
          this.trigger("typing");
          return false;
        }
        break;
    }
  }

  /**
   * Handles Ctrl/Cmd chords.
   *
   * @param {ShortcutEvent} event
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeydownSuperEvent(event) {
    switch (event.key) {
      case "Enter":
        return this.trigger("superEnter");
      case "ArrowLeft":
        if (this.isMac) {
          this.trigger("superLeft");
          return false;
        }
        break;
      case "ArrowUp":
        this.trigger("pageTop");
        return false;
      case "ArrowRight":
        if (this.isMac) {
          this.trigger("superRight");
          return false;
        }
        break;
      case "ArrowDown":
        this.trigger("pageBottom");
        return false;
      case ",":
        this.trigger("preferences");
        return false;
    }
  }

  /**
   * Handles Ctrl/Cmd + Shift chords.
   *
   * @param {ShortcutEvent} event
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeydownSuperShiftEvent(event) {
    switch (event.key) {
      case "ArrowUp":
        this.trigger("superShiftUp");
        return false;
      case "ArrowDown":
        this.trigger("superShiftDown");
        return false;
    }
  }

  /**
   * @param {ShortcutEvent} event
   * @param {boolean} [_force]
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeydownShiftEvent(event, _force) {
    if (
      !_force &&
      ARROW_KEYS.includes(event.key) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownEvent(event, true);
    }

    if (!event.target.form && LETTER_KEY.test(event.key)) {
      this.trigger("typing");
      return;
    }

    switch (event.key) {
      case " ":
        this.trigger("pageUp");
        return false;
      case "ArrowUp":
        if (!getSelection()?.toString()) {
          this.trigger("altUp");
          return false;
        }
        break;
      case "ArrowDown":
        if (!getSelection()?.toString()) {
          this.trigger("altDown");
          return false;
        }
        break;
    }
  }

  /**
   * @param {ShortcutEvent} event
   * @param {boolean} [_force]
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeydownAltEvent(event, _force) {
    if (
      !_force &&
      ARROW_KEYS.includes(event.key) &&
      this.swapArrowKeysBehavior()
    ) {
      return this.handleKeydownEvent(event, true);
    }

    switch (event.key) {
      case "Tab":
        return this.trigger("altRight", event);
      case "ArrowLeft":
        if (!this.isMac) {
          this.trigger("superLeft");
          return false;
        }
        break;
      case "ArrowUp":
        this.trigger("altUp");
        return false;
      case "ArrowRight":
        if (!this.isMac) {
          this.trigger("superRight");
          return false;
        }
        break;
      case "ArrowDown":
        this.trigger("altDown");
        return false;
    }

    // Alt rewrites the character a letter key produces (alt + s is "ß" on a
    // Mac), so the letter chords go by the key's position instead.
    switch (event.code) {
      case "KeyC":
        this.trigger("altC");
        return false;
      case "KeyD":
        this.trigger("altD");
        return false;
      case "KeyF":
        return this.trigger("altF", event);
      case "KeyG":
        this.trigger("altG");
        return false;
      case "KeyO":
        this.trigger("altO");
        return false;
      case "KeyR":
        this.trigger("altR");
        return false;
      case "KeyS":
        this.trigger("altS");
        return false;
    }
  }

  /**
   * @param {ShortcutEvent} event
   * @returns {unknown} `false` to swallow the event; anything else lets it through.
   */
  handleKeypressEvent(event) {
    if (event.key === "?" && !event.target.value) {
      this.trigger("help");
      return false;
    } else {
      return (this.lastKeypress = Date.now());
    }
  }
}
