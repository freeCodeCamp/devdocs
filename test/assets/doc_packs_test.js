// @ts-check

import assert from "node:assert/strict";
import test from "node:test";

import { DocPacks } from "../../assets/javascripts/app/doc_packs.js";
import {
  cleanIndex,
  DocPackError,
  findBuiltInDocs,
  packDocs,
  packId,
  packUrl,
  readManifest,
} from "../../assets/javascripts/lib/doc_packs.js";
import { Doc } from "../../assets/javascripts/models/doc.js";

const PACK_URL = "https://raw.githubusercontent.com/someone/docs/HEAD/";

test("a GitHub repository is read from its raw files", () => {
  assert.equal(packUrl("github.com/someone/docs"), PACK_URL);
  assert.equal(packUrl("https://github.com/someone/docs.git"), PACK_URL);
  assert.equal(
    packUrl("https://github.com/someone/docs/tree/v2/packs/vue"),
    "https://raw.githubusercontent.com/someone/docs/v2/packs/vue/",
  );
  assert.equal(
    packUrl("https://github.com/someone/docs/blob/main/docs.json"),
    "https://raw.githubusercontent.com/someone/docs/main/",
  );
});

test("other addresses are used as they are, as a folder", () => {
  assert.equal(packUrl("https://example.com/packs/docs.json"), "https://example.com/packs/");
  assert.equal(packUrl("someone.github.io/docs?x=1#top"), "https://someone.github.io/docs/");
  assert.equal(packUrl("http://localhost:8080"), "http://localhost:8080/");
});

test("addresses that can't be a pack are refused", () => {
  for (const input of [
    "",
    "   ",
    "not a url",
    "my docs",
    "notes",
    "https://intranet/docs",
    "http://example.com/docs", // plain http, except on this computer
    "javascript:alert(1)",
    "file:///C:/docs",
    "https://user:password@example.com/",
    "https://github.com/someone",
  ]) {
    assert.equal(packUrl(input), null, input);
  }
});

test("the pack's code is the same for the same address", () => {
  assert.equal(packId(PACK_URL), packId(PACK_URL));
  assert.notEqual(packId(PACK_URL), packId("https://example.com/"));
  assert.match(packId(PACK_URL), /^[a-z0-9]{6}$/);
});

test("pack docs get slugs of their own, and their own address", () => {
  const pack = readManifest(
    [
      { name: "Vue", slug: "vue~3", version: "3", mtime: 100, db_size: 2000 },
      { name: "Notes", slug: "notes" },
    ],
    PACK_URL,
  );
  const id = packId(PACK_URL);
  const [vue, notes] = packDocs(pack);

  assert.equal(pack.name, "someone/docs");
  assert.equal(vue.slug, `vue_${id}~3`);
  assert.equal(vue.origin, `${PACK_URL}vue~3/`);
  assert.equal(vue.source_slug, "vue~3");
  assert.equal(vue.pack, id);
  assert.equal(notes.slug, `notes_${id}`);
  assert.equal(notes.version, undefined);

  const doc = new Doc(vue);
  assert.equal(doc.version, "3");
  assert.equal(doc.icon, "doc-pack");
  assert.equal(doc.indexUrl(), `${PACK_URL}vue~3/index.json?100`);
  assert.equal(doc.dbUrl(), `${PACK_URL}vue~3/db.json?100`);
  assert.equal(doc.fileUrl("guide/intro.html"), `${PACK_URL}vue~3/guide/intro.html?100`);
});

test("built-in docs are still served from DevDocs", () => {
  const doc = new Doc({ name: "HTML", slug: "html", mtime: 5 });
  // The test config serves DevDocs' docs from the page's own origin.
  assert.equal(doc.indexUrl(), "/html/index.json?5");
  assert.equal(doc.fileUrl("element/a.html"), "/html/element/a.html?5");
});

test("a manifest can name its pack", () => {
  const pack = readManifest({ name: "My <b>notes</b>", docs: [{ name: "A", slug: "a" }] }, PACK_URL);
  assert.equal(pack.name, "My bnotes/b");
});

test("manifests that aren't a pack, or list no usable doc, are refused", () => {
  for (const json of [null, "docs", { docs: "x" }, [], [{ name: "No slug" }], [{ slug: "no_name" }]]) {
    assert.throws(() => readManifest(json, PACK_URL), DocPackError);
  }
});

test("markup and unsafe values in a manifest are dropped", () => {
  const [doc] = packDocs(
    readManifest(
      [
        {
          name: 'Vue<img src=x onerror="alert(1)">',
          slug: "vue",
          version: '3"><script>',
          type: "mdn onclick",
          mtime: "soon",
          db_size: -4,
          links: {
            home: "javascript:alert(1)",
            code: 'https://example.com/"><b>',
            other: "https://example.com/",
          },
          attribution: '&copy; Someone <a href="https://example.com">site</a><script>x</script>',
        },
      ],
      PACK_URL,
    ),
  );

  assert.equal(doc.name, "Vueimg src=x onerror=alert(1)");
  assert.equal(doc.version, "3script");
  assert.equal(doc.type, undefined);
  assert.equal(doc.mtime, 0);
  assert.equal(doc.db_size, 0);
  assert.deepEqual(doc.links, { code: "https://example.com/%22%3E%3Cb%3E" });
  assert.equal(doc.attribution, "&copy; Someone sitex");
});

test("slugs that would break links, routes or settings are refused", () => {
  const pack = readManifest(
    [
      { name: "OK", slug: "ok" },
      { name: "Hyphen", slug: "my-docs" },
      { name: "Slash", slug: "a/b" },
      { name: "Upper", slug: "Vue" },
      { name: "Quote", slug: 'a"b' },
      { name: "Twice", slug: "ok" },
    ],
    PACK_URL,
  );
  assert.deepEqual(
    packDocs(pack).map((doc) => doc.source_slug),
    ["ok"],
  );
});

test("index entries that would break out of a link are dropped", () => {
  const index = cleanIndex({
    entries: [
      { name: "Intro", path: "guide/intro", type: "Guide" },
      { name: "Section", path: "guide/intro#setup", type: "Guide" },
      { name: "<b>Escaped later</b>", path: "tags", type: "Guide" },
      { name: "Quote", path: 'a" onmouseover="x' },
      { name: "Space", path: "a b" },
      { name: "Absolute", path: "/other" },
      { name: "Up", path: "../other_doc/page" },
      { name: "Not a string", path: 5 },
      "not an object",
    ],
    types: [
      { name: "Guide", slug: "guide", count: 3 },
      { name: "Bad", slug: 'x"y', count: 1 },
    ],
  });

  assert.deepEqual(
    index.entries.map((entry) => entry.path),
    ["guide/intro", "guide/intro#setup", "tags"],
  );
  assert.deepEqual(index.types, [{ name: "Guide", slug: "guide", count: 3 }]);
  assert.deepEqual(cleanIndex("nonsense"), { entries: [], types: [] });
});

test("a pack doc's index is cleaned when it loads", () => {
  const [attributes] = packDocs(readManifest([{ name: "Vue", slug: "vue" }], PACK_URL));
  const doc = new Doc(attributes);
  doc.reset({ entries: [{ name: "Ok", path: "ok" }, { name: "Bad", path: 'x"' }], types: [] });
  assert.deepEqual(
    doc.entries.all().map((entry) => entry.path),
    ["ok"],
  );
});

/** A stand-in for LocalStorageStore. */
const memoryStore = () => {
  const data = new Map();
  return {
    get: (key) => data.get(key),
    set: (key, value) => {
      data.set(key, JSON.parse(JSON.stringify(value)));
      return true;
    },
    del: (key) => data.delete(key),
    reset: () => data.clear(),
  };
};

test("added packs are stored, listed and removed", async () => {
  const packs = new DocPacks(/** @type {any} */ (memoryStore()));
  packs.fetch = (url, callback) =>
    callback(null, readManifest([{ name: "Vue", slug: "vue" }], url));

  const add = (input) =>
    new Promise((resolve) => packs.add(input, (error, pack) => resolve({ error, pack })));

  const { error, pack } = await add("github.com/someone/docs");
  assert.equal(error, null);
  assert.equal(pack.url, PACK_URL);
  assert.deepEqual(
    packs.docs().map((doc) => doc.slug),
    [`vue_${packId(PACK_URL)}`],
  );

  assert.match((await add("https://github.com/someone/docs")).error.message, /already added/);
  assert.equal((await add("https://github.com/someone/docs")).error.reason, "duplicate");
  assert.equal((await add("not a url")).error.reason, "address");
  assert.equal((await add("http://example.com/docs")).error.reason, "insecure");

  assert.equal(packs.remove(PACK_URL)?.url, PACK_URL);
  assert.deepEqual(packs.all(), []);
});

test("a failed download says whether the pack is missing or unreachable", async () => {
  const packs = new DocPacks(/** @type {any} */ (memoryStore()));
  const ajaxError = (status) =>
    new Promise((resolve) => {
      // A request that fails with the given status, as ajax() sees it.
      globalThis.XMLHttpRequest = /** @type {any} */ (
        class {
          readyState = 0;
          status = 0;
          responseText = "";
          onreadystatechange = () => {};
          open() {}
          setRequestHeader() {}
          send() {
            this.readyState = 4;
            this.status = status;
            setTimeout(() => this.onreadystatechange());
          }
        }
      );
      packs.add("https://example.com/pack/", (error) => resolve(error));
    });

  try {
    assert.equal((await ajaxError(404)).reason, "missing");
    assert.equal((await ajaxError(0)).reason, "unreachable");
  } finally {
    delete globalThis.XMLHttpRequest;
  }
});

test("an address that a built-in doc comes from is recognized", () => {
  const docs = [
    { name: "Vue", links: { home: "https://vuejs.org/", code: "https://github.com/vuejs/core" } },
    { name: "Vue Router", links: { home: "https://router.vuejs.org/" } },
    { name: "Git", links: { home: "https://git-scm.com/docs" } },
    { name: "Pack doc" },
  ];

  assert.deepEqual(findBuiltInDocs("vuejs.org/guide/introduction.html", docs), ["Vue"]);
  assert.deepEqual(findBuiltInDocs("https://www.github.com/vuejs/core", docs), ["Vue"]);
  assert.deepEqual(findBuiltInDocs("https://git-scm.com/docs/git-commit", docs), ["Git"]);
  assert.deepEqual(findBuiltInDocs("https://git-scm.com/", docs), ["Git"]);
  assert.deepEqual(findBuiltInDocs("https://git-scm.com/book", docs), []);
  assert.deepEqual(findBuiltInDocs("https://docs.github.com/en/pages", docs), []);
  assert.deepEqual(findBuiltInDocs("", docs), []);
});
