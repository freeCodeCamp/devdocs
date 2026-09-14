// @ts-check

/**
 * A minimal event emitter. Most of the app's long-lived objects extend it.
 *
 * Event names are free-form strings; `on`, `off` and `removeEvent` also accept
 * several of them separated by spaces. Every event is re-emitted as `all` with
 * the original name prepended to the arguments.
 *
 * Listeners know the shape of the event they subscribed to, which the
 * emitter itself has no way to express, so the arguments stay untyped.
 *
 * @typedef {(...args: unknown[]) => void} EventCallback
 */
export class Events {
  /**
   * Registered callbacks, keyed by event name. Created on first `on` call.
   *
   * @type {Record<string, EventCallback[]> | undefined}
   */
  _callbacks;

  /**
   * The event being dispatched, while `trigger` is running.
   *
   * @type {{ name: string, args: unknown[] } | null}
   */
  eventInProgress;

  /**
   * @param {string} event One or more event names, separated by spaces.
   * @param {EventCallback} callback
   * @returns {this}
   */
  on(event, callback) {
    if (event.includes(" ")) {
      for (var name of event.split(" ")) {
        this.on(name, callback);
      }
    } else {
      this._callbacks ||= {};
      this._callbacks[event] ||= [];
      this._callbacks[event].push(callback);
    }
    return this;
  }

  /**
   * @param {string} event One or more event names, separated by spaces.
   * @param {EventCallback} callback The same reference that was passed to `on`.
   * @returns {this}
   */
  off(event, callback) {
    let callbacks, index;
    if (event.includes(" ")) {
      for (var name of event.split(" ")) {
        this.off(name, callback);
      }
    } else if (
      (callbacks = this._callbacks?.[event]) &&
      (index = callbacks.indexOf(callback)) >= 0
    ) {
      callbacks.splice(index, 1);
      if (!callbacks.length) {
        delete this._callbacks[event];
      }
    }
    return this;
  }

  /**
   * @param {string} event A single event name.
   * @param {...unknown} args Passed on to each callback.
   * @returns {this}
   */
  trigger(event, ...args) {
    this.eventInProgress = { name: event, args };
    const callbacks = this._callbacks?.[event];
    if (callbacks) {
      for (const callback of callbacks.slice(0)) {
        if (typeof callback === "function") {
          callback(...args);
        }
      }
    }
    this.eventInProgress = null;
    if (event !== "all") {
      this.trigger("all", event, ...args);
    }
    return this;
  }

  /**
   * Removes every callback registered for the given events.
   *
   * @param {string} event One or more event names, separated by spaces.
   * @returns {this}
   */
  removeEvent(event) {
    if (this._callbacks != null) {
      for (var name of event.split(" ")) {
        delete this._callbacks[name];
      }
    }
    return this;
  }
}
