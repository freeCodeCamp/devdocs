// Exports the offline data (the pages stored in IndexedDB and the index files
// cached in localStorage) to a JSON file, and imports it back — either to
// restore a backup after the browser evicted the data, or to move the
// documentations to another computer without downloading them again.
app.OfflineBackup = class OfflineBackup {
  static TYPE = "devdocs-offline";
  static VERSION = 1;
  static MIME_TYPE = "application/json";

  filename(docs) {
    const date = new Date().toISOString().slice(0, 10);
    const name = docs.length === 1 ? docs[0].slug : "offline";
    return `devdocs-${name}-${date}.json`;
  }

  // Calls back with a Blob containing every installed doc among `docs`, and
  // the number of docs it holds. Docs that aren't installed are skipped.
  export(docs, onProgress, onSuccess, onError) {
    const chunks = [
      `{"type":"${OfflineBackup.TYPE}","version":${
        OfflineBackup.VERSION
      },"date":"${new Date().toISOString()}","docs":[`,
    ];
    let count = 0;
    let i = 0;

    var next = () => {
      const doc = docs[i++];

      if (!doc) {
        if (count === 0) {
          onError("empty");
          return;
        }
        chunks.push("]}");
        onSuccess(new Blob(chunks, { type: OfflineBackup.MIME_TYPE }), count);
        return;
      }

      onProgress(doc, i, docs.length);
      app.db.dump(doc, (result) => {
        if (result) {
          // Serialize each doc on its own instead of building one big object,
          // to avoid holding the whole backup in memory twice.
          chunks.push(
            (count++ === 0 ? "" : ",") +
              JSON.stringify(this.serializeDoc(doc, result)),
          );
        }
        setTimeout(next, 0);
      });
    };

    next();
  }

  serializeDoc(doc, result) {
    const entry = { slug: doc.slug, mtime: result.mtime, db: result.data };
    const index = app.localStorage.get(doc.slug);
    // Ship the index file too, so that the doc can be used on a computer that
    // never downloaded it (the app falls back to the network otherwise).
    if (index && index[0] === result.mtime) {
      entry.index = index[1];
    }
    return entry;
  }

  import(file, onProgress, onSuccess, onError) {
    if (!file || (file.type && file.type !== OfflineBackup.MIME_TYPE)) {
      onError("invalid");
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const data = (() => {
        try {
          return JSON.parse(reader.result);
        } catch (error) {}
      })();

      if (!data || data.type !== OfflineBackup.TYPE || !Array.isArray(data.docs)) {
        onError("invalid");
        return;
      }
      if (data.version > OfflineBackup.VERSION) {
        onError("version");
        return;
      }

      this.importDocs(data.docs, onProgress, onSuccess, onError);
    };
    reader.onerror = () => onError("invalid");
    reader.readAsText(file);
  }

  importDocs(entries, onProgress, onSuccess, onError) {
    const queue = [];
    const skipped = [];

    for (var entry of entries) {
      var doc = this.isValidEntry(entry) && this.findDoc(entry.slug);
      if (doc) {
        queue.push([doc, entry]);
      } else {
        skipped.push(typeof entry?.slug === "string" ? entry.slug : "?");
      }
    }

    if (queue.length === 0) {
      onError("unknown", skipped);
      return;
    }

    const enabled = this.enableDocs(queue.map(([doc]) => doc));
    const total = queue.length;
    const imported = [];
    const failed = [];
    let i = 0;

    var next = () => {
      const item = queue[i++];

      if (!item) {
        onSuccess({ docs: imported, skipped, failed, enabled });
        return;
      }

      const [doc, entry] = item;
      const mtime = entry.mtime;
      onProgress(doc, i, total);

      if (this.isValidIndex(entry.index)) {
        // Keyed by the backup's mtime so that Doc#_getCache discards it when
        // the documentation has been updated since the backup was made.
        app.localStorage.set(doc.slug, [mtime, entry.index]);
      }

      app.db.store(
        doc,
        entry.db,
        mtime,
        () => {
          imported.push(doc);
          setTimeout(next, 0);
        },
        () => {
          failed.push(doc.slug);
          setTimeout(next, 0);
        },
      );
    };

    next();
  }

  // Storing a doc clears whatever was installed before it, so an entry that
  // isn't usable has to be rejected rather than wipe a working installation.
  // The index page is what DB#checkForCorruptedDocs looks for.
  isValidEntry(entry) {
    return (
      entry != null &&
      typeof entry.slug === "string" &&
      Number.isSafeInteger(entry.mtime) &&
      entry.mtime > 0 &&
      entry.db?.constructor === Object &&
      typeof entry.db.index === "string" &&
      entry.db.index.length > 0
    );
  }

  isValidIndex(index) {
    return (
      index?.constructor === Object &&
      Array.isArray(index.entries) &&
      Array.isArray(index.types)
    );
  }

  findDoc(slug) {
    return (
      app.docs.findBy("slug", slug) || app.disabledDocs.findBy("slug", slug)
    );
  }

  // Enabling the docs up-front is what makes their object stores exist: the
  // schema bump triggers DB#onUpgradeNeeded, which only creates stores for the
  // enabled docs. Returns the number of docs that weren't enabled before.
  enableDocs(docs) {
    let enabled = 0;

    for (var doc of docs) {
      if (app.docs.contains(doc)) {
        continue;
      }
      app.disabledDocs.remove(doc);
      app.docs.add(doc);
      enabled += 1;
    }

    if (enabled > 0) {
      app.docs.sort();
      app.saveDocs();
    }

    return enabled;
  }
};
