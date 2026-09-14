/**
 * Ambient declarations for the assets.
 *
 * The assets are ES modules, so each file's own types travel with its exports.
 * This file covers what has no module to live in:
 *
 *   - the vendored libraries, which are excluded from the typecheck,
 *   - the shapes the models and views acquire at runtime, and
 *   - the DOM-event aliases the views share.
 *
 * Everything else lives in JSDoc next to the code that implements it.
 */

export {};

declare global {
  // --- Vendored libraries (assets/javascripts/vendor) ---

  /** Raven.js — the Sentry browser client. Only the parts the app uses. */
  const Raven: {
    config(dsn: string, options?: Record<string, any>): typeof Raven;
    install(): typeof Raven;
    captureException(error: unknown, options?: Record<string, any>): void;
    captureMessage(message: string, options?: Record<string, any>): void;
  };

  /** Prism.js — only the parts the app uses. */
  const Prism: {
    highlightElement(element: Element, async?: boolean): void;
  };

  // --- View events ---

  /**
   * A DOM event as a view handler reads it.
   *
   * lib.dom types `Event#target` as a bare `EventTarget`, which carries none of
   * the element properties a handler reads. The handlers are bound to elements,
   * so the target is narrowed to one; the form variants narrow it further, for
   * the handlers bound to a field.
   */
  type ViewEvent = Event & { target: HTMLElement; currentTarget: HTMLElement };
  type ViewMouseEvent = MouseEvent & { target: HTMLElement; currentTarget: HTMLElement };
  type ViewKeyboardEvent = KeyboardEvent & { target: HTMLElement; currentTarget: HTMLElement };
  type ViewInputEvent = Event & { target: HTMLInputElement; currentTarget: HTMLElement };

  // --- Analytics, loaded at runtime by tracking.js ---

  /** Google Analytics, once analytics.js has loaded. */
  var ga: (...args: unknown[]) => void;

  /** Gauges' command queue. */
  var _gauges: unknown[] | undefined;

  // --- Augmentations ---

  interface Window {
    /** Present when running inside Electron. */
    readonly process?: { versions?: Record<string, string> };

    /** Set by vendor/mathml.js once it has probed for MathML support. */
    supportsMathML?: boolean;

    /** Gauges' command queue. */
    _gauges?: unknown[];

    /** debug.js — prints the view tree, with each view's activation state. */
    viewTree?: (view?: unknown, level?: number, visited?: unknown[]) => void;
  }

  interface Navigator {
    /** Global Privacy Control. Not in lib.dom yet. */
    readonly globalPrivacyControl?: boolean;
  }

  interface XMLHttpRequest {
    /** Set by lib/ajax.js so that the timeout can be cleared when it settles. */
    timer?: ReturnType<typeof setTimeout>;
  }
}

// --- Model and view shapes ---

/*
 * The models copy their attributes onto themselves and the views have their
 * `elements` selectors resolved by the base constructor, so neither can
 * declare those properties as fields without blanking them out again. They
 * are merged into each class from here instead.
 */

declare module "./models/doc.js" {
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
    /**
     * From the manifest, which always emits the key and sets it to null when the
     * doc has no alias.
     */
    alias: string | null;

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
    entries: import("./collections/entries.js").Entries;
    /** The doc's types, once its index has loaded. */
    types: import("./collections/types.js").Types;
    /** The entry standing for the doc itself, built on demand. */
    entry?: import("./models/entry.js").Entry;
    /** Set while an install or uninstall is running. */
    installing?: boolean | null;
  }
}

declare module "./models/entry.js" {
  interface Entry {
    /** From the doc's index. */
    name: string;
    /** From the doc's index. Relative to the doc, and may carry a hash. */
    path: string;
    /** From the doc's index. The name of the type the entry belongs to. */
    type?: string;
    /** Set by the doc when it builds its entries. */
    doc: import("./models/doc.js").Doc;
    /** Derived: what the searcher matches against. */
    text: string | string[];
  }
}

declare module "./models/type.js" {
  interface Type {
    /** From the doc's index. */
    name: string;
    /** From the doc's index. */
    slug: string;
    /** From the doc's index. How many entries it holds. */
    count: number;
    /** Set by the doc when it builds its types. */
    doc: import("./models/doc.js").Doc;
  }
}

declare module "./views/list/paginated_list.js" {
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
}

declare module "./views/pages/base.js" {
  interface BasePage {
    /** Implemented by the subclass, when it has anything to do after rendering. */
    afterRender?(): void;
    entry: import("./models/entry.js").Entry;
    highlightNodes: HTMLElement[];
    nodesPerFrame: number;
    previousTiming: number | null;
  }
}

declare module "./views/layout/mobile.js" {
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
}

declare module "./views/layout/settings.js" {
  interface SettingsView {
    /** From `elements`. */
    sidebar: HTMLElement;
    /** From `elements`. */
    saveBtn: HTMLElement;
    /** From `elements`. */
    backBtn: HTMLElement;

    docPicker: import("./views/sidebar/doc_picker.js").DocPicker;
    saving?: boolean;
  }
}

declare module "./views/search/search.js" {
  interface Search {
    /** From `elements`. */
    input: HTMLInputElement;
    /** From `elements`. */
    resetLink: HTMLElement;

    scope: import("./views/search/search_scope.js").SearchScope;
    searcher: import("./app/searcher.js").Searcher;
    value: string;
    hasResults: boolean | null;
    flags: { urlSearch?: boolean, initialResults?: boolean };
  }
}

declare module "./views/search/search_scope.js" {
  interface SearchScope {
    /** From `elements`. */
    input: HTMLInputElement;
    /** From `elements`. */
    tag: HTMLElement;

    doc: import("./models/doc.js").Doc | null;
    placeholder: string;
    searcher: import("./app/searcher.js").SynchronousSearcher;
  }
}

declare module "./views/sidebar/doc_list.js" {
  interface DocList {
    /** From `elements`. */
    disabledTitle: HTMLElement;
    /** From `elements`. */
    disabledList: HTMLElement;

    lists: Record<string, import("./views/sidebar/type_list.js").TypeList | import("./views/sidebar/entry_list.js").EntryList>;
    listFocus: import("./views/list/list_focus.js").ListFocus;
    listFold: import("./views/list/list_fold.js").ListFold;
    listSelect: import("./views/list/list_select.js").ListSelect;
  }
}
