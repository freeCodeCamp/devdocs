// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
this.LocalStorageStore = class LocalStorageStore {
  get(key) {
    try {
      return JSON.parse(localStorage.getItem(key));
    } catch (error) {}
  }

  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {}
  }

  del(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {}
  }

  reset() {
    try {
      localStorage.clear();
      return true;
    } catch (error) {}
  }
};
