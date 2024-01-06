// Intentionally called CookiesStore instead of CookieStore
// Calling it CookieStore causes issues when the Experimental Web Platform features flag is enabled in Chrome
// Related issue: https://github.com/freeCodeCamp/devdocs/issues/932
class CookiesStore {
  static INT = /^\d+$/;

  static onBlocked() {}

  get(key) {
    let value = Cookies.get(key);
    if (value != null && CookiesStore.INT.test(value)) {
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
      (typeof CookiesStore.INT.test === "function"
        ? CookiesStore.INT.test(value)
        : undefined)
    ) {
      value = parseInt(value, 10);
    }
    Cookies.set(key, "" + value, { path: "/", expires: 1e8 });
    if (this.get(key) !== value) {
      CookiesStore.onBlocked(key, value, this.get(key));
    }
  }

  del(key) {
    Cookies.expire(key);
  }

  reset() {
    try {
      for (var cookie of document.cookie.split(/;\s?/)) {
        Cookies.expire(cookie.split("=")[0]);
      }
      return;
    } catch (error) {}
  }

  dump() {
    const result = {};
    for (var cookie of document.cookie.split(/;\s?/)) {
      if (cookie[0] !== "_") {
        cookie = cookie.split("=");
        result[cookie[0]] = cookie[1];
      }
    }
    return result;
  }
}
