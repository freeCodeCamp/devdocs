// @ts-check

import { LocalStorageStore } from "./local_storage_store.js";

/**
 * A cookie-backed key/value store.
 *
 * Values round-trip as strings, so integers are parsed back out on read and
 * booleans are stored as `1` / absent. When a write doesn't stick — the usual
 * cause is the browser blocking cookies — `onBlocked` is called so the app can
 * warn the user.
 *
 * Every value is also mirrored in localStorage, because cookies alone don't
 * last: Safari and Brave cap a cookie written from a script to seven days
 * however far ahead its expiry date is set, and a browser under pressure may
 * evict one sooner. Losing the cookies loses the enabled docs with them, and
 * the app then wipes the offline data that went with them, so the mirror is
 * copied back over the cookies on the next visit.
 * Related issue: https://github.com/freeCodeCamp/devdocs/issues/1765
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

  /** The localStorage key the cookies are mirrored under. */
  static MIRROR_KEY = "settings";

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
   * @param {CookieValue} value
   * @returns {CookieValue} `value`, as a number when it is all digits.
   */
  static parse(value) {
    return value != null && CookiesStore.INT.test(String(value))
      ? parseInt(String(value), 10)
      : value;
  }

  /**
   * Cookies travel percent-encoded, and `Cookies.set` encodes what it is
   * given, so a value read straight off `document.cookie` has to be decoded
   * before it can be written back or it gains a round of escaping each time.
   *
   * @param {string} value
   * @returns {string} `value`, decoded, or as it stands when it isn't valid
   *   percent-encoding.
   */
  static decode(value) {
    try {
      return decodeURIComponent(value);
    } catch (error) {
      return value;
    }
  }

  /**
   * Writes a cookie with the lifetime the app asks for. How much of that the
   * browser honours is up to it — hence the mirror.
   *
   * @param {string} key
   * @param {string} value
   */
  static writeCookie(key, value) {
    Cookies.set(key, value, { path: "/", expires: 1e8 });
  }

  /** Opens the mirror and puts back the cookies the browser has dropped. */
  constructor() {
    this.storage = new LocalStorageStore();
    this.mirrored = this.restore();
  }

  /**
   * @param {string} key
   * @returns {CookieValue} The stored value, as a number when it is all digits.
   */
  get(key) {
    // The mirror answers first: it is seeded from the cookies at boot and kept
    // in step with every write afterwards, so it holds what the app last
    // stored even when the browser refused the cookie — a cookie the user's
    // list of docs has outgrown, typically.
    const value = this.mirrored[key];
    return CookiesStore.parse(value != null ? value : Cookies.get(key));
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
    value = CookiesStore.parse(value);

    this.save(key, "" + value);

    // Read the cookie itself rather than going through `get`, so that a value
    // the mirror is holding on to doesn't hide a cookie the browser refused.
    const actual = CookiesStore.parse(Cookies.get(key));
    if (actual !== value) {
      CookiesStore.onBlocked(key, value, actual);
    }
  }

  /** @param {string} key */
  del(key) {
    Cookies.expire(key);
    this.save(key, undefined);
  }

  /** Expires every cookie on the document, and empties the mirror. */
  reset() {
    this.mirrored = {};
    this.storage.del(CookiesStore.MIRROR_KEY);
    try {
      for (var cookie of document.cookie.split(/;\s?/)) {
        Cookies.expire(cookie.split("=")[0]);
      }
      return;
    } catch (error) {}
  }

  /**
   * @returns {Record<string, string>} Everything the store holds, unparsed.
   */
  dump() {
    return { ...this.mirrored };
  }

  /**
   * @returns {Record<string, string>} Every non-internal cookie on the
   *   document, decoded but otherwise unparsed.
   */
  cookies() {
    const result = {};
    for (var cookie of document.cookie.split(/;\s?/)) {
      if (cookie && cookie[0] !== "_") {
        const [name, value] = cookie.split("=");
        result[CookiesStore.decode(name)] = CookiesStore.decode(value || "");
      }
    }
    return result;
  }

  /**
   * Stores `key` in the cookies and in the mirror, or deletes it from both
   * when `value` is `undefined`.
   *
   * @param {string} key
   * @param {string | undefined} value
   */
  save(key, value) {
    const stored = this.read();

    if (value !== undefined) {
      CookiesStore.writeCookie(key, value);
      this.mirrored[key] = stored[key] = value;
    } else {
      delete this.mirrored[key];
      delete stored[key];
    }

    // What is on disk is changed a key at a time, so that a setting another
    // tab has written since this one read the mirror isn't rolled back.
    this.storage.set(CookiesStore.MIRROR_KEY, stored);
  }

  /**
   * Takes the mirror as the record of what is stored, and writes back the
   * cookies that have since gone missing.
   *
   * Cookies that are still there win, and seed the mirror: they are what the
   * server has just been told, they are what another tab may have changed in
   * the meantime, and they cover the visitors whose settings predate the
   * mirror.
   *
   * @returns {Record<string, string>} The mirrored values.
   */
  restore() {
    const mirrored = { ...this.read(), ...this.cookies() };

    for (var key in mirrored) {
      if (Cookies.get(key) === undefined) {
        CookiesStore.writeCookie(key, mirrored[key]);
      }
    }

    this.storage.set(CookiesStore.MIRROR_KEY, mirrored);
    return mirrored;
  }

  /**
   * @returns {Record<string, string>} The mirror, or an empty object when it is
   *   missing or unreadable.
   */
  read() {
    const mirrored = this.storage.get(CookiesStore.MIRROR_KEY);
    return mirrored && typeof mirrored === "object"
      ? /** @type {Record<string, string>} */ ({ ...mirrored })
      : {};
  }
}
