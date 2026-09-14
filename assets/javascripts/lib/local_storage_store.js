// @ts-check

/**
 * A JSON-encoded wrapper around `localStorage`.
 *
 * Every method swallows the exceptions the browser throws when storage is
 * unavailable (private browsing, blocked cookies, quota exhausted) and reports
 * failure by returning `undefined`.
 */
this.LocalStorageStore = class LocalStorageStore {
  /**
   * @param {string} key
   * @returns {any} The stored value, or `undefined` if it is missing or unreadable.
   */
  get(key) {
    try {
      return JSON.parse(localStorage.getItem(key));
    } catch (error) {}
  }

  /**
   * @param {string} key
   * @param {any} value
   * @returns {boolean | undefined} `true` when stored, `undefined` when it failed.
   */
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {}
  }

  /**
   * @param {string} key
   * @returns {boolean | undefined} `true` when removed, `undefined` when it failed.
   */
  del(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {}
  }

  /**
   * @returns {boolean | undefined} `true` when cleared, `undefined` when it failed.
   */
  reset() {
    try {
      localStorage.clear();
      return true;
    } catch (error) {}
  }
};
