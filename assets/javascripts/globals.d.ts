/**
 * Ambient declarations for the assets.
 *
 * Sprockets concatenates every file in `application.js` into a single script,
 * so the assets share one global scope. TypeScript picks up top-level `class`,
 * `function`, `const`, `let` and `var` declarations across files on its own;
 * this file covers the two things it cannot see:
 *
 *   - globals created by assigning to `this` at the top level of a file, and
 *   - the vendored libraries, which are excluded from the typecheck.
 *
 * The types themselves live in JSDoc next to the code that implements them.
 */

// --- Globals defined by assigning to `this` at the top level ---

/** lib/util.js — queries one element, and carries the DOM helpers. */
declare var $: DollarQuery & DollarHelpers;

/** lib/util.js — queries every matching element. */
declare var $$: DollarQueryAll;

// --- Vendored libraries (assets/javascripts/vendor) ---

/** Cookies.js — github.com/ScottHamper/Cookies */
declare const Cookies: {
  (key: string): string | undefined;
  (key: string, value: string, options?: CookieOptions): typeof Cookies;
  get(key: string): string | undefined;
  set(key: string, value: string, options?: CookieOptions): typeof Cookies;
  expire(key: string, options?: CookieOptions): typeof Cookies;
  defaults: CookieOptions;
  enabled: boolean;
};

interface CookieOptions {
  path?: string;
  domain?: string;
  expires?: number | string | Date;
  secure?: boolean;
}

/** Raven.js — the Sentry browser client. Only the parts the app uses. */
declare const Raven: {
  config(dsn: string, options?: Record<string, any>): typeof Raven;
  install(): typeof Raven;
  captureException(error: unknown, options?: Record<string, any>): void;
  captureMessage(message: string, options?: Record<string, any>): void;
};

/** Prism.js — only the parts the app uses. */
declare const Prism: {
  highlightElement(element: Element, async?: boolean): void;
};

// --- Augmentations ---

interface XMLHttpRequest {
  /** Set by lib/ajax.js so that the timeout can be cleared when it settles. */
  timer?: number;
}
