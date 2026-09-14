// @ts-check

/**
 * A cookie-backed key/value store.
 *
 * Values round-trip as strings, so integers are parsed back out on read and
 * booleans are stored as `1` / absent. When a write doesn't stick — the usual
 * cause is the browser blocking cookies — `onBlocked` is called so the app can
 * warn the user.
 *
 * Intentionally called CookiesStore instead of CookieStore. Calling it
 * CookieStore causes issues when the Experimental Web Platform features flag is
 * enabled in Chrome.
 * Related issue: https://github.com/freeCodeCamp/devdocs/issues/932
 *
 * @typedef {string | number | undefined} CookieValue
 */
export class CookiesStore {
  static INT = /^\d+$/;

  /**
   * Hook called when a value read back after a write doesn't match what was
   * written. Replaced by the app at boot; a no-op by default.
   *
   * @param {string} key
   * @param {CookieValue | boolean} value The value that was written.
   * @param {CookieValue} actual The value that was read back.
   */
  static onBlocked(key, value, actual) {}

  /**
   * @param {string} key
   * @returns {CookieValue} The stored value, as a number when it is all digits.
   */
  get(key) {
    /** @type {CookieValue} */
    let value = Cookies.get(key);
    if (value != null && CookiesStore.INT.test(value)) {
      value = parseInt(value, 10);
    }
    return value;
  }

  /**
   * Writing `false` deletes the key; `true` is stored as `1`.
   *
   * @param {string} key
   * @param {CookieValue | boolean} value
   */
  set(key, value) {
    if (value === false) {
      this.del(key);
      return;
    }

    if (value === true) {
      value = 1;
    }
    if (
      value &&
      (typeof CookiesStore.INT.test === "function"
        ? CookiesStore.INT.test(/** @type {string} */ (value))
        : undefined)
    ) {
      value = parseInt(/** @type {string} */ (value), 10);
    }
    Cookies.set(key, "" + value, { path: "/", expires: 1e8 });
    if (this.get(key) !== value) {
      CookiesStore.onBlocked(key, value, this.get(key));
    }
  }

  /** @param {string} key */
  del(key) {
    Cookies.expire(key);
  }

  /** Expires every cookie on the document. */
  reset() {
    try {
      for (var cookie of document.cookie.split(/;\s?/)) {
        Cookies.expire(cookie.split("=")[0]);
      }
      return;
    } catch (error) {}
  }

  /**
   * @returns {Record<string, string>} Every non-internal cookie, unparsed.
   */
  dump() {
    const result = {};
    for (var cookie of document.cookie.split(/;\s?/)) {
      if (cookie[0] !== "_") {
        const [name, value] = cookie.split("=");
        result[name] = value;
      }
    }
    return result;
  }
}
