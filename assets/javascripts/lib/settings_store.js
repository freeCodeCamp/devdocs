// @ts-check

import { LocalStorageStore } from "./local_storage_store.js";

/**
 * The user's settings, kept as one JSON object in localStorage.
 *
 * Values round-trip as strings, so integers are parsed back out on read and
 * booleans are stored as `1` / absent — the shape the settings backup file has
 * always had. When a write doesn't stick — storage turned off, private
 * browsing, an exhausted quota — `onBlocked` is called so the app can warn the
 * user.
 *
 * The settings used to be cookies, so that the server could read the enabled
 * docs and render a service worker that precached them. Nothing server-side
 * reads them any more, and cookies were the wrong place regardless: Safari and
 * Brave cap a cookie written from a script at seven days however far ahead its
 * expiry is set, so the settings quietly reset themselves — and the app wiped
 * the offline data that went with them.
 * Related issue: https://github.com/freeCodeCamp/devdocs/issues/1765
 *
 * @typedef {string | number | undefined} SettingValue
 */
export class SettingsStore {
  /** The localStorage key everything is stored under. */
  static KEY = "settings";

  static INT = /^\d+$/;

  /**
   * Hook called when a value read back after a write doesn't match what was
   * written. Replaced by the app at boot; a no-op by default.
   *
   * @param {string} key
   * @param {SettingValue | boolean} value The value that was written.
   * @param {SettingValue} actual The value that was read back.
   */
  static onBlocked(key, value, actual) {}

  /**
   * @param {SettingValue} value
   * @returns {SettingValue} `value`, as a number when it is all digits.
   */
  static parse(value) {
    return value != null && SettingsStore.INT.test(String(value))
      ? parseInt(String(value), 10)
      : value;
  }

  /** Opens the store and takes in whatever is still in cookies. */
  constructor() {
    this.storage = new LocalStorageStore();
    this.migrate();
  }

  /**
   * @param {string} key
   * @returns {SettingValue} The stored value, as a number when it is all digits.
   */
  get(key) {
    return SettingsStore.parse(this.dump()[key]);
  }

  /**
   * Writing `false` deletes the key; `true` is stored as `1`.
   *
   * @param {string} key
   * @param {SettingValue | boolean} value
   */
  set(key, value) {
    if (value === false) {
      this.del(key);
      return;
    }

    if (value === true) {
      value = 1;
    }
    value = SettingsStore.parse(value);

    const settings = this.dump();
    settings[key] = "" + value;
    this.write(settings);

    const actual = this.get(key);
    if (actual !== value) {
      SettingsStore.onBlocked(key, value, actual);
    }
  }

  /** @param {string} key */
  del(key) {
    const settings = this.dump();
    delete settings[key];
    this.write(settings);
  }

  /** Clears every setting. */
  reset() {
    this.storage.del(SettingsStore.KEY);
  }

  /**
   * @returns {Record<string, string>} Every setting, unparsed. Read back out of
   *   storage each time, so that a second tab's writes aren't held stale.
   */
  dump() {
    const settings = this.storage.get(SettingsStore.KEY);
    return settings && typeof settings === "object"
      ? /** @type {Record<string, string>} */ (settings)
      : {};
  }

  /** @param {Record<string, string>} settings */
  write(settings) {
    this.storage.set(SettingsStore.KEY, settings);
  }

  /**
   * Takes in the settings an earlier version of the app left in cookies, and
   * expires them. Does nothing once they are gone.
   *
   * What is already stored wins, being the newer of the two. Cookies with a
   * single leading underscore belong to the analytics vendors, not to us.
   */
  migrate() {
    const settings = this.dump();
    let found = false;

    // Reading document.cookie throws where cookies are turned off entirely.
    try {
      for (var cookie of document.cookie.split(/;\s?/)) {
        if (!cookie || cookie[0] === "_") {
          continue;
        }
        const [name, value] = cookie.split("=");
        const key = decode(name);

        // analyticsConsentAsked was a session cookie, and is sessionStorage now.
        if (key !== "analyticsConsentAsked" && !(key in settings)) {
          settings[key] = decode(value || "");
          found = true;
        }
        document.cookie = `${name}=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT`;
      }
    } catch (error) {}

    if (found) {
      this.write(settings);
    }
  }
}

/**
 * @param {string} value
 * @returns {string} `value`, decoded, or as it stands when it isn't valid
 *   percent-encoding. Cookies travelled percent-encoded; the store doesn't.
 */
const decode = (value) => {
  try {
    return decodeURIComponent(value);
  } catch (error) {
    return value;
  }
};

/** The one store. It keeps no state of its own beyond what is in storage. */
export const settingsStore = new SettingsStore();
