# Client-Side Storage

DevDocs is a client-side app: the Sinatra server only serves the app shell,
static assets, and the scraped documentation files. Which docs a user selected
and what is available offline lives entirely in the browser, across four
independent layers. Notably, the server does **not** read any of this to render
the app.

## 1. Enabled-docs list → cookie (`docs`)

The selected doc slugs, joined by `/` (e.g. `css/html/javascript~5`).

- **Where:** a browser cookie `docs` (the settings store is a `CookiesStore`).
- **Read/written:** `Settings#getDocs` (falls back to `default_docs`) /
  `Settings#setDocs`, toggled in the Settings page
  ([`app/settings.js`](../assets/javascripts/app/settings.js)).
- **Used at boot:** `App#bootAll` splits the full catalog into `app.docs`
  (enabled) and `app.disabledDocs` ([`app/app.js`](../assets/javascripts/app/app.js)).

Only this item is a cookie rather than `localStorage`, and it no longer needs to
be — nothing server-side reads it.

## 2. Per-doc index (`index.json`) → localStorage

The table of contents (entries + types) that powers the sidebar and search — not
the page content. In [`models/doc.js`](../assets/javascripts/models/doc.js):

- **Where:** `app.localStorage` (`LocalStorageStore`), keyed by doc slug, value
  `[mtime, data]`.
- **Read:** `Doc#_getCache` returns data only if the stored `mtime` matches;
  otherwise it clears the stale entry.
- **Written / updated:** `Doc#load({readCache, writeCache})` reads `localStorage`
  first (a hit ⇒ no network); on a miss (first enable or changed `mtime`) it
  fetches `index.json` and writes it back. Runs for every enabled doc at boot via
  `Docs#load`.

## 3. Doc content (page HTML) → IndexedDB, or fetched live

Two modes, in [`app/db.js`](../assets/javascripts/app/db.js):

- **Not installed (default):** fetched **per page, on demand** —
  `DB#loadWithXHR` → `entry.fileUrl()`. Not stored.
- **Installed for offline** (explicit download or `autoInstall`): `Doc#install`
  fetches the whole `db.json`; `DB#store` writes every entry's HTML into
  **IndexedDB** (one object store per slug, plus a `docs` store mapping slug →
  `mtime`).
- **Read:** `DB#load` uses IndexedDB when the doc is installed, else falls back
  to network.

## 4. App shell + fetched index files → Service Worker Cache

What makes the app work offline. Two parts with different justifications
([`views/service-worker.js.erb`](../views/service-worker.js.erb)):

- **App shell (essential).** On install, precaches `/`, favicon, manifest, and
  the fingerprinted JS/CSS/sprites. Offline, *something* must answer the request
  for the HTML document and assets; `localStorage`/IndexedDB can't (they're read
  only after the app is running). A service worker is the only primitive that can
  serve navigations/assets with no network — this is why offline works at all.
  The precache list is kept doc-independent so a flaky doc index can't fail the
  atomic `cache.addAll` install.
- **Index files (fallback for layer 2's quota).** The `fetch` handler also caches
  same-origin `index.json` at runtime. This seems redundant with layer 2, but
  `localStorage` has a ~5 MB quota and `LocalStorageStore.set` swallows
  `QuotaExceededError` silently — so with many/large docs, some indexes never
  persist there and are re-fetched offline. Only the Cache API (far larger quota)
  can then satisfy them, making the service worker the reliable high-capacity
  index store, with `localStorage` as the fast first hit.

## Summary

| Layer | What | Storage | Written when |
| --- | --- | --- | --- |
| Enabled list | doc slugs | Cookie `docs` | toggled in Settings |
| Doc index | TOC / entries / types (`index.json`) | `localStorage`, `[mtime, data]` per slug | `Doc#load` fetch (enable / `mtime` change) |
| Doc content | page HTML | IndexedDB per slug (installed); else live XHR | `Doc#install` → `DB#store` |
| Shell + index copy | JS/CSS/sprites + `index.json` | Service Worker Cache | SW install (shell) + runtime fetch (index) |

Layers 1–3 are client-managed and drive the running app. Layer 4 lets it boot
offline (the shell) and backstops layer 2 when the index exceeds `localStorage`'s
quota.
