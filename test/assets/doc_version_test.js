const assert = require("node:assert/strict");
const fs = require("node:fs");
const test = require("node:test");
const vm = require("node:vm");

const context = {
  $: {},
  $$: {},
  page: {},
  window: { matchMedia: () => ({ media: "not all" }) },
};

vm.createContext(context);

// The files are concatenated because top-level class declarations aren't
// shared between scripts run in the same context.
vm.runInContext(
  [
    "assets/javascripts/lib/events.js",
    "assets/javascripts/app/app.js",
    "assets/javascripts/models/model.js",
    "assets/javascripts/models/doc.js",
    "assets/javascripts/collections/collection.js",
    "assets/javascripts/collections/docs.js",
  ]
    .map((file) => fs.readFileSync(file, "utf8"))
    .join("\n"),
  context,
  { filename: "devdocs.js" },
);

const { app } = context;

app.collections.Entries = class Entries {
  each() {}
};
app.collections.Types = class Types {
  each() {}
};
app.models.Entry = class Entry {
  addAlias() {}
};

const CMAKE = [
  { name: "CMake", slug: "cmake~3.12", version: "3.12" },
  { name: "CMake", slug: "cmake~3.10", version: "3.10" },
  { name: "CMake", slug: "cmake~3.9", version: "3.9" },
];
const NODE = [
  { name: "Node.js", slug: "node", version: "" },
  { name: "Node.js", slug: "node~10_lts", version: "10 LTS" },
  { name: "Node.js", slug: "node~8_lts", version: "8 LTS" },
];
const BASH = [{ name: "Bash", slug: "bash" }];

const newDoc = (attributes) => new app.models.Doc(attributes);
const findLatest = (slug, attributes) => {
  const docs = attributes.map(newDoc);
  return docs.find((doc) => doc.slug === slug).findLatestVersion(docs).slug;
};

test("the latest version of a documentation compares versions numerically", () => {
  assert.equal(findLatest("cmake~3.9", CMAKE), "cmake~3.12");
  assert.equal(findLatest("cmake~3.12", CMAKE), "cmake~3.12");
  assert.equal(
    findLatest("bazel~9", [
      { name: "Bazel", slug: "bazel~10", version: "10" },
      { name: "Bazel", slug: "bazel~9", version: "9" },
    ]),
    "bazel~10",
  );
});

test("a documentation without a version is the latest version", () => {
  const docs = [
    { name: "Angular", slug: "angular", version: "" },
    { name: "Angular", slug: "angular~5", version: "5" },
  ];
  assert.equal(findLatest("angular~5", docs), "angular");
  assert.equal(findLatest("angular", docs), "angular");
});

test("documentations that aren't versioned have no latest version", () => {
  assert.equal(findLatest("bash", BASH), "bash");
});

test("variants of a documentation aren't versions", () => {
  // Node.js 10 LTS isn't superseded by the unversioned (latest) Node.js doc,
  // and neither is a Haxe target by the base Haxe doc.
  assert.equal(findLatest("node~10_lts", NODE), "node~10_lts");
  assert.equal(
    findLatest("haxe~python", [
      { name: "Haxe", slug: "haxe", version: "" },
      { name: "Haxe", slug: "haxe~python", version: "Python" },
    ]),
    "haxe~python",
  );
});

// The index of the latest version has to load for a doc to be replaced.
app.models.Doc.prototype.load = function (onSuccess, onError) {
  if (app.loadFails) {
    onError();
  } else {
    onSuccess();
  }
};

const migrate = async (enabled, allDocs, autoLatestVersion = true) => {
  app.settings = {
    get: (key) => (key === "autoLatestVersion" ? autoLatestVersion : undefined),
  };
  app.docs = new app.collections.Docs();
  app.disabledDocs = new app.collections.Docs();
  for (const attributes of allDocs) {
    (enabled.includes(attributes.slug) ? app.docs : app.disabledDocs).add(
      attributes,
    );
  }
  app.saveDocs = () => {
    app.saved = true;
  };
  app.saved = false;
  await app.migrateToLatestVersions();
  // Spread the array so that it's created in this realm, not the VM's.
  return [...app.docs.all().map((doc) => doc.slug)];
};

test("enabled docs are migrated to their latest version at boot", async () => {
  assert.deepEqual(await migrate(["cmake~3.9", "bash"], [...CMAKE, ...BASH]), [
    "bash",
    "cmake~3.12",
  ]);
  assert.equal(app.saved, true);
  assert.equal(app.disabledDocs.findBy("slug", "cmake~3.9").slug, "cmake~3.9");
});

test("outdated docs are disabled when their latest version is already enabled", async () => {
  assert.deepEqual(await migrate(["cmake~3.9", "cmake~3.12"], CMAKE), [
    "cmake~3.12",
  ]);
});

test("a doc whose latest version fails to load isn't replaced", async () => {
  app.loadFails = true;
  try {
    assert.deepEqual(await migrate(["cmake~3.9"], CMAKE), ["cmake~3.9"]);
    assert.equal(app.saved, false);
  } finally {
    app.loadFails = false;
  }
});

test("docs are left alone without the preference or a newer version", async () => {
  assert.deepEqual(await migrate(["cmake~3.9"], CMAKE, false), ["cmake~3.9"]);
  assert.equal(app.saved, false);

  assert.deepEqual(
    await migrate(["cmake~3.12", "node~10_lts"], [...CMAKE, ...NODE]),
    ["cmake~3.12", "node~10_lts"],
  );
  assert.equal(app.saved, false);
});
