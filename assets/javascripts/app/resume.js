// @ts-check

/** @import { LocalStorageStore } from "../lib/local_storage_store.js" */

/**
 * "Resume where I left off": the doc page being read is remembered, with how
 * far down it's scrolled, and when DevDocs is next opened on its home page it
 * goes back there. Opening a link to a particular page still opens that page.
 *
 * Kept in this browser's local storage, like the other per-person state.
 */
export class Resume {
  static STORAGE_KEY = "lastPage";

  /** How long scrolling has to stop before the position is stored. */
  static SCROLL_DELAY = 400;

  /** @param {LocalStorageStore} store */
  constructor(store) {
    this.store = store;
  }

  /** @returns {{ path: string, scrollTop: number } | null} The page last read. */
  last() {
    const value = /** @type {{ path?: unknown, scrollTop?: unknown } | null | undefined} */ (
      this.store.get(Resume.STORAGE_KEY)
    );
    if (
      !value ||
      typeof value.path !== "string" ||
      // Only paths within DevDocs.
      !value.path.startsWith("/") ||
      value.path.startsWith("//")
    ) {
      return null;
    }
    return { path: value.path, scrollTop: Math.max(0, Number(value.scrollTop) || 0) };
  }

  /**
   * Remembers the page being read, at its top.
   *
   * @param {string} path
   */
  remember(path) {
    if (this.last()?.path !== path) {
      this.store.set(Resume.STORAGE_KEY, { path, scrollTop: 0 });
    }
  }

  /**
   * Remembers how far down the page being read is scrolled.
   *
   * @param {number} scrollTop
   */
  rememberScroll(scrollTop) {
    const last = this.last();
    if (last) {
      this.store.set(Resume.STORAGE_KEY, { path: last.path, scrollTop: Math.round(scrollTop) });
    }
  }

  /**
   * The page to reopen when DevDocs starts at `location`: only when it starts
   * on the home page with nothing in the address after it (a link to a page,
   * or a search, goes where it says), and only a page of a doc that's still
   * enabled.
   *
   * @param {{ pathname: string, search: string, hash: string }} location
   * @param {(slug: string) => boolean} isEnabled Whether a doc's slug is enabled.
   * @returns {{ path: string, scrollTop: number } | null}
   */
  target(location, isEnabled) {
    if (location.pathname !== "/" || location.search || location.hash) {
      return null;
    }
    const last = this.last();
    // "/css/..." or a type page, "/css-properties/".
    const slug = last?.path.split("/")[1]?.split("-")[0];
    return last && slug && isEnabled(slug) ? last : null;
  }
}
