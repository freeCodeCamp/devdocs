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
declare var setFaviconForDoc: (doc: unknown) => void;

/** lib/favicon.js — restores the default favicon. */
declare var resetFavicon: () => void;

/** debug.js — prints the view tree, with each view's activation state. */
declare var viewTree: (view?: unknown, level?: number, visited?: unknown[]) => void;

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

// --- Model attributes ---

/**
 * The models' own properties.
 *
 * Model copies the attributes it is constructed with onto itself, so a model's
 * properties are decided by the manifest rather than declared on the class,
 * and a field declaration would run after `super()` and blank them out again.
 * These interfaces merge into the classes instead.
 *
 * Merging suppresses the inference of `this.x = ...`, so the properties each
 * model derives for itself are declared here too.
 */

interface Doc {
  /** From the manifest. */
  name: string;
  /** From the manifest. Carries the version, e.g. `html~5`. */
  slug: string;
  /** From the manifest. The scraper that produced the doc. */
  type: string;
  /**
   * From the manifest. Absent for docs that aren't versioned at all, and empty
   * for the doc holding the latest version.
   */
  version?: string;
  /** From the manifest. The upstream version the doc was built from. */
  release?: string;
  /** From the manifest. When the doc was last built; also its cache key. */
  mtime?: number;
  /** From the manifest. The offline database's size, in bytes. */
  db_size?: number;
  /** From the manifest. The documentation's own home and source URLs. */
  links?: Record<string, string>;
  /** From the manifest. The licence notice shown on the About page. */
  attribution?: string;
  /** From the manifest. An alternative spelling of the doc's name. */
  alias?: string;

  /** Derived: the slug without its version. */
  slug_without_version: string;
  /** Derived: the name with the version appended. */
  fullName: string;
  /** Derived: which sprite to show. */
  icon: string;
  /** Derived: the version up to its first space. */
  short_version?: string;
  /** Derived: what the searcher matches against. */
  text: string | string[];

  /** The doc's entries, once its index has loaded. */
  entries: Entries;
  /** The doc's types, once its index has loaded. */
  types: Types;
  /** The entry standing for the doc itself, built on demand. */
  entry?: Entry;
  /** Set while an install or uninstall is running. */
  installing?: boolean | null;
}

interface Entry {
  /** From the doc's index. */
  name: string;
  /** From the doc's index. Relative to the doc, and may carry a hash. */
  path: string;
  /** From the doc's index. The name of the type the entry belongs to. */
  type?: string;
  /** Set by the doc when it builds its entries. */
  doc: Doc;
  /** Derived: what the searcher matches against. */
  text: string | string[];
}

interface Type {
  /** From the doc's index. */
  name: string;
  /** From the doc's index. */
  slug: string;
  /** From the doc's index. How many entries it holds. */
  count: number;
  /** Set by the doc when it builds its types. */
  doc: Doc;
}

/**
 * The properties the `elements` static injects.
 *
 * The base class resolves those selectors onto the instance from inside its
 * own constructor, before a subclass's field initializers would run, so they
 * can't be declared as fields without being blanked out again. These
 * interfaces merge them into the classes instead.
 *
 * Merging suppresses the inference of `this.x = ...`, so each view's own
 * properties are declared here too.
 */

/**
 * The two base views whose subclasses supply a hook the base calls. Declaring
 * the hook here is what lets the base reference it.
 */
interface PaginatedList {
  /** Implemented by the subclass: renders one page of rows. */
  render(data: unknown[]): string;
  data: unknown[];
  page: number;
}

interface BasePage {
  /** Implemented by the subclass, when it has anything to do after rendering. */
  afterRender?(): void;
  entry: Entry;
  highlightNodes: HTMLElement[];
  nodesPerFrame: number;
  previousTiming: number | null;
}

interface Mobile {
  /** From `elements`. */
  body: HTMLElement;
  /** From `elements`. */
  content: HTMLElement;
  /** From `elements`. */
  sidebar: HTMLElement;
  /** From `elements`. */
  docPicker: HTMLElement;

  back: HTMLElement;
  forward: HTMLElement;
  toggleSidebar: HTMLElement;
  docPickerTab: HTMLElement;
  settingsTab: HTMLElement;
  contentTop: number;
  sidebarTop: number;
}

interface SettingsView {
  /** From `elements`. */
  sidebar: HTMLElement;
  /** From `elements`. */
  saveBtn: HTMLElement;
  /** From `elements`. */
  backBtn: HTMLElement;

  docPicker: DocPicker;
  saving?: boolean;
}

interface Search {
  /** From `elements`. */
  input: HTMLInputElement;
  /** From `elements`. */
  resetLink: HTMLElement;

  scope: SearchScope;
  searcher: Searcher;
  value: string;
  hasResults: boolean | null;
  flags: { urlSearch?: boolean, initialResults?: boolean };
}

interface SearchScope {
  /** From `elements`. */
  input: HTMLInputElement;
  /** From `elements`. */
  tag: HTMLElement;

  doc: Doc | null;
  placeholder: string;
  searcher: SynchronousSearcher;
}

interface DocList {
  /** From `elements`. */
  disabledTitle: HTMLElement;
  /** From `elements`. */
  disabledList: HTMLElement;

  lists: Record<string, TypeList | EntryList>;
  listFocus: ListFocus;
  listFold: ListFold;
  listSelect: ListSelect;
}

// --- Analytics, loaded at runtime by tracking.js ---

/** Google Analytics, once analytics.js has loaded. */
declare var ga: (...args: unknown[]) => void;

/** Gauges' command queue. */
declare var _gauges: unknown[] | undefined;

// --- Augmentations ---

interface Window {
  /** Present when running inside Electron. */
  readonly process?: { versions?: Record<string, string> };

  /** Set by vendor/mathml.js once it has probed for MathML support. */
  supportsMathML?: boolean;

  /** Gauges' command queue. */
  _gauges?: unknown[];
}

interface Navigator {
  /** Global Privacy Control. Not in lib.dom yet. */
  readonly globalPrivacyControl?: boolean;
}

interface XMLHttpRequest {
  /** Set by lib/ajax.js so that the timeout can be cleared when it settles. */
  timer?: number;
}
