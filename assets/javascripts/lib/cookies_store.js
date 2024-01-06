// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
(function () {
  let INT = undefined;
  const Cls = (this.CookiesStore = class CookiesStore {
    static initClass() {
      // Intentionally called CookiesStore instead of CookieStore
      // Calling it CookieStore causes issues when the Experimental Web Platform features flag is enabled in Chrome
      // Related issue: https://github.com/freeCodeCamp/devdocs/issues/932

      INT = /^\d+$/;
    }

    static onBlocked() {}

    get(key) {
      let value = Cookies.get(key);
      if (value != null && INT.test(value)) {
        value = parseInt(value, 10);
      }
      return value;
    }

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
        (typeof INT.test === "function" ? INT.test(value) : undefined)
      ) {
        value = parseInt(value, 10);
      }
      Cookies.set(key, "" + value, { path: "/", expires: 1e8 });
      if (this.get(key) !== value) {
        this.constructor.onBlocked(key, value, this.get(key));
      }
    }

    del(key) {
      Cookies.expire(key);
    }

    reset() {
      try {
        for (var cookie of Array.from(document.cookie.split(/;\s?/))) {
          Cookies.expire(cookie.split("=")[0]);
        }
        return;
      } catch (error) {}
    }

    dump() {
      const result = {};
      for (var cookie of Array.from(document.cookie.split(/;\s?/))) {
        if (cookie[0] !== "_") {
          cookie = cookie.split("=");
          result[cookie[0]] = cookie[1];
        }
      }
      return result;
    }
  });
  Cls.initClass();
  return Cls;
})();
