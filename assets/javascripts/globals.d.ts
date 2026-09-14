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

/** lib/local_storage_store.js — a JSON-encoded wrapper around localStorage. */
declare var LocalStorageStore: new () => LocalStorageStore;

/** lib/page.js — the router. */
declare var page: PageFn & PageHelpers;

/** lib/page.js — expires the analytics cookies. */
declare var resetAnalytics: () => void;

/** app/app.js — the application singleton. */
declare var app: App;

/** lib/favicon.js — swaps the favicon for the doc's icon. */
declare var setFaviconForDoc: (doc: any) => void;

/** lib/favicon.js — restores the default favicon. */
declare var resetFavicon: () => void;

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

// --- Analytics, loaded at runtime by tracking.js ---

/** Google Analytics, once analytics.js has loaded. */
declare var ga: (...args: any[]) => void;

/** Gauges' command queue. */
declare var _gauges: any[] | undefined;

// --- Augmentations ---

interface Window {
  /** Present when running inside Electron. */
  readonly process?: { versions?: Record<string, string> };

  /** Set by vendor/mathml.js once it has probed for MathML support. */
  supportsMathML?: boolean;

  /** Gauges' command queue. */
  _gauges?: any[];
}

interface Navigator {
  /** Global Privacy Control. Not in lib.dom yet. */
  readonly globalPrivacyControl?: boolean;
}

interface XMLHttpRequest {
  /** Set by lib/ajax.js so that the timeout can be cleared when it settles. */
  timer?: number;
}
