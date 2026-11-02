// @ts-check

/**
 * Doc packs: documentation published by anyone, outside DevDocs' own catalog.
 *
 * A pack is a folder served over HTTPS — a Git repository on GitHub, or any
 * website that lets other sites read its files (CORS) — laid out like DevDocs'
 * own docs folder: a docs.json manifest listing the docs, and one folder per
 * doc slug holding index.json, db.json and the pages as .html files. A copy of
 * the public/docs folder that `thor docs:generate` and `thor docs:manifest`
 * produce is therefore a pack as it is.
 *
 * Nothing in a pack is trusted. Its docs get slugs of their own, so they can't
 * replace a built-in doc or one from another pack, and everything that ends up
 * in the page is checked here first: names and versions lose markup, links
 * have to be http(s), entry paths can't break out of an attribute, and pages
 * go through DOMPurify before they're shown.
 *
 * This module has no dependency on the app, so it can be tested under Node.
 */

import { isCategoryId } from "../app/categories.js";

export const MANIFEST_FILENAME = "docs.json";

/** A pack may list at most this many docs; anything past it is ignored. */
export const MAX_DOCS = 500;

/**
 * Doc slugs as DevDocs writes them: lower case, with an optional version after
 * a tilde, e.g. `html~5` or `node~10_lts`. No hyphen, which the router reads as
 * the start of a type (`/:doc-:type/`), and no slash, which separates the
 * enabled slugs in the settings.
 */
const SLUG_RGX = /^[a-z0-9_.]+(?:~[a-z0-9_.]+)?$/;

/** The scraper types that pick a page's styling, e.g. `mdn`. */
const TYPE_RGX = /^[a-z_]+$/;

/** Type slugs go into a URL and an attribute. */
const TYPE_SLUG_RGX = /^[\w.-]+$/;

/** Characters that could end an attribute or open a tag. */
const MARKUP_RGX = /[<>"'`\u0000-\u001f]/g;

/**
 * An entry path is appended to `/<slug>/` in links, and to the pack's address
 * when the page is fetched.
 */
const SAFE_PATH_RGX = /^[^\s"'`<>\\]+$/;

/** Where to send people who want to find or make a pack. */
export const GUIDE_URL =
  "https://github.com/buggypather/devdocs/blob/custom-doc-packs/docs/doc-packs.md";
export const FIND_PACKS_URL = "https://github.com/topics/devdocs-pack";

/**
 * Why a pack couldn't be added, so the preferences can say what to do next.
 *
 * @typedef {"address" | "insecure" | "duplicate" | "missing" | "unreachable" | "invalid" | "storage"} DocPackErrorReason
 */

/** A problem with a pack, worded for the person who added it. */
export class DocPackError extends Error {
  name = "DocPackError";

  /**
   * @param {string} message
   * @param {DocPackErrorReason} reason
   */
  constructor(message, reason) {
    super(message);
    this.reason = reason;
  }
}

/**
 * @typedef {object} StoredPack
 * @property {string} url The pack's folder, ending in a slash.
 * @property {string} id Short code that makes the pack's slugs unique.
 * @property {string} name Shown in the preferences.
 * @property {Record<string, unknown>[]} docs The manifest as downloaded.
 * @property {number} [fetchedAt] When the manifest was last downloaded.
 */

/**
 * Turns what someone pastes into the pack's folder URL, ending in a slash.
 *
 * - `github.com/owner/repo` reads the default branch from
 *   raw.githubusercontent.com, which serves the files with CORS headers;
 *   `/tree/<branch>/<folder>` picks a branch and a folder in the repository.
 * - Any other address is used as it is, minus a trailing `docs.json`.
 *
 * @param {unknown} input
 * @returns {string | null} `null` when it isn't a usable address.
 */
export function packUrl(input) {
  let text = String(input ?? "").trim();
  if (!text || /\s/.test(text)) {
    return null;
  }
  if (!/^[a-z][a-z0-9+.-]*:\/\//i.test(text)) {
    text = `https://${text}`;
  }

  let url;
  try {
    url = new URL(text);
  } catch (error) {
    return null;
  }
  // A site's name has a dot in it (example.com); only this computer doesn't.
  if (!url.hostname.includes(".") && !isLocal(url)) {
    return null;
  }
  // Plain http only for a pack being tested on this computer.
  if (url.protocol !== "https:" && !(url.protocol === "http:" && isLocal(url))) {
    return null;
  }
  if (url.username || url.password) {
    return null;
  }

  const segments = url.pathname.split("/").filter(Boolean).map(decodeSegment);
  if (segments.includes(null) || segments.includes("..")) {
    return null;
  }
  if (segments.at(-1) === MANIFEST_FILENAME) {
    segments.pop();
  }

  if (url.hostname === "github.com" || url.hostname === "www.github.com") {
    const [owner, repo, kind, ref, ...folder] = segments;
    if (!owner || !repo) {
      return null;
    }
    const inTree = (kind === "tree" || kind === "blob") && ref;
    return rawGitHubUrl(owner, repo.replace(/\.git$/, ""), inTree ? ref : "HEAD", inTree ? folder : []);
  }

  return url.origin + "/" + segments.map((s) => encodeURIComponent(s) + "/").join("");
}

/**
 * @param {string} owner
 * @param {string} repo
 * @param {string} ref A branch, tag or commit; `HEAD` is the default branch.
 * @param {string[]} folder
 * @returns {string}
 */
function rawGitHubUrl(owner, repo, ref, folder) {
  return (
    "https://raw.githubusercontent.com/" +
    [owner, repo, ref, ...folder].map((s) => encodeURIComponent(s) + "/").join("")
  );
}

/** @param {URL} url */
function isLocal(url) {
  return ["localhost", "127.0.0.1", "[::1]"].includes(url.hostname);
}

/** @param {string} segment */
function decodeSegment(segment) {
  try {
    return decodeURIComponent(segment);
  } catch (error) {
    return null;
  }
}

/**
 * A short code for the pack, from its URL, so the same pack always gets the
 * same slugs (and keeps its enabled and installed docs across visits). FNV-1a,
 * in base 36.
 *
 * @param {string} url
 * @returns {string}
 */
export function packId(url) {
  let hash = 0x811c9dc5;
  for (let i = 0; i < url.length; i++) {
    hash ^= url.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(36).padStart(7, "0").slice(-6);
}

/**
 * The name a pack is shown under when its manifest doesn't give one: the
 * GitHub owner and repository, or the host and folder.
 *
 * @param {string} url A URL returned by `packUrl`.
 * @returns {string}
 */
export function defaultPackName(url) {
  const { hostname, pathname } = new URL(url);
  const segments = pathname.split("/").filter(Boolean).map((s) => decodeSegment(s) || s);
  if (hostname === "raw.githubusercontent.com") {
    const [owner, repo, ref, ...folder] = segments;
    return [`${owner}/${repo}`, ...folder].join("/") + (ref === "HEAD" ? "" : ` (${ref})`);
  }
  return [hostname, ...segments].join("/");
}

/**
 * Checks a downloaded docs.json and turns it into a pack to store.
 *
 * The manifest is either DevDocs' own format, an array of docs, or an object
 * with a `docs` array and an optional `name`.
 *
 * @param {unknown} json
 * @param {string} url A URL returned by `packUrl`.
 * @returns {StoredPack}
 * @throws {DocPackError} When it isn't a pack, or lists no usable doc.
 */
export function readManifest(json, url) {
  const list = Array.isArray(json)
    ? json
    : isObject(json) && Array.isArray(json.docs)
      ? json.docs
      : null;
  if (!list) {
    throw new DocPackError(
      `${MANIFEST_FILENAME} should list the pack's docs, but it doesn't look like a doc pack.`,
      "invalid",
    );
  }

  const docs = list.filter(isObject).slice(0, MAX_DOCS);
  const pack = {
    url,
    id: packId(url),
    name: cleanText(isObject(json) && !Array.isArray(json) ? json.name : null) || defaultPackName(url),
    docs,
  };
  if (packDocs(pack).length === 0) {
    throw new DocPackError(
      `${MANIFEST_FILENAME} lists no usable docs. Each needs a name and a slug such as "my_notes" or "my_notes~2".`,
      "invalid",
    );
  }
  return pack;
}

/**
 * The pack's docs as the app's manifest attributes, with the docs that aren't
 * valid left out.
 *
 * @param {StoredPack} pack
 * @returns {Record<string, unknown>[]}
 */
export function packDocs(pack) {
  const seen = new Set();
  const docs = [];
  for (const raw of pack.docs || []) {
    const doc = packDoc(raw, pack);
    if (doc && !seen.has(doc.slug)) {
      seen.add(doc.slug);
      docs.push(doc);
    }
  }
  return docs;
}

/**
 * @param {Record<string, unknown>} raw One doc from the pack's manifest.
 * @param {StoredPack} pack
 * @returns {Record<string, unknown> | null}
 */
function packDoc(raw, pack) {
  const sourceSlug = typeof raw.slug === "string" ? raw.slug.trim() : "";
  const name = cleanText(raw.name);
  if (!SLUG_RGX.test(sourceSlug) || !name) {
    return null;
  }
  const [base, version] = sourceSlug.split("~");

  return {
    name,
    // The pack's code goes before the version, which has to stay last.
    slug: `${base}_${pack.id}` + (version ? `~${version}` : ""),
    // Absent means unversioned and empty means the latest version, so the
    // difference is kept.
    version: typeof raw.version === "string" ? cleanText(raw.version) : undefined,
    release: cleanText(raw.release) || undefined,
    type: typeof raw.type === "string" && TYPE_RGX.test(raw.type) ? raw.type : undefined,
    mtime: nonNegative(raw.mtime),
    db_size: nonNegative(raw.db_size),
    links: cleanLinks(raw.links),
    attribution: cleanText(stripTags(raw.attribution), 1000) || undefined,
    alias: null,
    origin: `${pack.url}${encodeURIComponent(sourceSlug)}/`,
    pack: pack.id,
    source_slug: sourceSlug,
    // One of app/categories.js' ids; anything else is "Other".
    category: isCategoryId(raw.category) ? raw.category : undefined,
  };
}

/**
 * The built-in docs whose website or source code is at the address someone
 * tried to add as a pack, e.g. `vuejs.org/guide` or `github.com/vuejs/docs`
 * for Vue. Best match first.
 *
 * @param {unknown} input
 * @param {{ name: string, links?: Record<string, string> }[]} docs
 * @returns {string[]} The docs' names, once each.
 */
export function findBuiltInDocs(input, docs) {
  const target = parseLoosely(input);
  if (!target) {
    return [];
  }

  /** @type {Map<string, number>} */
  const scores = new Map();
  for (const doc of docs) {
    for (const link of Object.values(doc.links || {})) {
      const url = parseLoosely(link);
      if (!url || url.host !== target.host) {
        continue;
      }
      // Either address may be the other's parent: the site's root for a doc
      // that lives in a folder, or a page deep inside the doc.
      const shared = commonSegments(url.segments, target.segments);
      if (shared === Math.min(url.segments.length, target.segments.length)) {
        scores.set(doc.name, Math.max(scores.get(doc.name) ?? -1, shared));
      }
    }
  }
  return [...scores].sort((a, b) => b[1] - a[1]).map(([name]) => name);
}

/**
 * @param {unknown} input
 * @returns {{ host: string, segments: string[] } | null}
 */
function parseLoosely(input) {
  let text = String(input ?? "").trim();
  if (!/^[a-z][a-z0-9+.-]*:\/\//i.test(text)) {
    text = `https://${text}`;
  }
  try {
    const url = new URL(text);
    return {
      host: url.hostname.replace(/^www\./, ""),
      segments: url.pathname
        .toLowerCase()
        .split("/")
        .filter(Boolean)
        .filter((segment) => !/^(index\.html?|docs\.json)$/.test(segment)),
    };
  } catch (error) {
    return null;
  }
}

/**
 * @param {string[]} a
 * @param {string[]} b
 */
function commonSegments(a, b) {
  let i = 0;
  while (i < a.length && i < b.length && a[i] === b[i]) {
    i++;
  }
  return i;
}

/**
 * Keeps the entries and types of a pack's index.json that are safe to put in
 * a link.
 *
 * @param {unknown} data
 * @returns {{ entries: Record<string, unknown>[], types: Record<string, unknown>[] }}
 */
export function cleanIndex(data) {
  const index = isObject(data) ? data : {};
  const entries = (Array.isArray(index.entries) ? index.entries : [])
    .filter(isObject)
    .filter((entry) => typeof entry.name === "string" && isSafePath(entry.path))
    .map((entry) => ({
      name: entry.name,
      path: entry.path,
      type: typeof entry.type === "string" ? entry.type : undefined,
    }));
  const types = (Array.isArray(index.types) ? index.types : [])
    .filter(isObject)
    .filter(
      (type) =>
        typeof type.name === "string" &&
        typeof type.slug === "string" &&
        TYPE_SLUG_RGX.test(type.slug),
    )
    .map((type) => ({ name: type.name, slug: type.slug, count: nonNegative(type.count) }));
  return { entries, types };
}

/**
 * @param {unknown} path
 * @returns {path is string}
 */
function isSafePath(path) {
  return (
    typeof path === "string" &&
    SAFE_PATH_RGX.test(path) &&
    !path.startsWith("/") &&
    !path.split(/[/#]/).includes("..")
  );
}

/**
 * Cleans a page from a pack before it's shown: no scripts, event handlers,
 * `javascript:` links, forms or styles that could restyle the app around it.
 * Pages of DevDocs' own docs are cleaned when they're scraped, so only pack
 * pages go through this.
 *
 * @param {string} html
 * @returns {string}
 */
export function cleanPage(html) {
  return DOMPurify.sanitize(html, {
    FORBID_TAGS: ["style", "form", "input", "button", "select", "textarea"],
    FORBID_ATTR: ["style"],
  });
}

/**
 * @param {unknown} value
 * @param {number} [maxLength]
 * @returns {string}
 */
function cleanText(value, maxLength = 100) {
  if (typeof value !== "string" && typeof value !== "number") {
    return "";
  }
  return String(value).replace(MARKUP_RGX, "").trim().slice(0, maxLength);
}

/** @param {unknown} value */
function stripTags(value) {
  return typeof value === "string" ? value.replace(/<[^>]*>/g, "") : value;
}

/**
 * @param {unknown} value
 * @returns {Record<string, string> | undefined} The `home` and `code` links
 *   that are http(s) URLs.
 */
function cleanLinks(value) {
  if (!isObject(value)) {
    return undefined;
  }
  const links = {};
  for (const key of ["home", "code"]) {
    const link = value[key];
    if (typeof link !== "string") {
      continue;
    }
    try {
      const url = new URL(link);
      if (url.protocol === "https:" || url.protocol === "http:") {
        // Serializing percent-encodes quotes and angle brackets.
        links[key] = url.href;
      }
    } catch (error) {}
  }
  return Object.keys(links).length ? links : undefined;
}

/** @param {unknown} value */
function nonNegative(value) {
  const number = Number(value);
  return Number.isFinite(number) && number > 0 ? Math.floor(number) : 0;
}

/**
 * @param {unknown} value
 * @returns {value is Record<string, any>}
 */
function isObject(value) {
  return typeof value === "object" && value !== null;
}
