// @ts-check

import { app } from "./app.js";
/** @import { Doc } from "../models/doc.js" */

/**
 * One doc as it appears in a backup file. Unrelated to the Entry model: these
 * are the records the backup's `docs` array holds.
 *
 * @typedef {object} BackupEntry
 * @property {string} slug
 * @property {number} mtime The build the stored pages came from.
 * @property {Record<string, string>} db The doc's pages, by path.
 * @property {unknown} [index] The doc's entry index, when the backup carried it.
 */

/**
 * What an import ended up doing.
 *
 * @typedef {object} ImportSummary
 * @property {Doc[]} docs The docs that were stored.
 * @property {string[]} skipped Slugs in the file that this app doesn't know, or that were unusable.
 * @property {string[]} failed The slugs of the docs whose store failed.
 * @property {number} enabled How many of the docs weren't enabled before.
 */

/**
 * Exports the offline data (the pages and the index files, both in IndexedDB)
 * to a JSON file, and imports it back — either to
 * restore a backup after the browser evicted the data, or to move the
 * documentations to another computer without downloading them again.
 */
export class OfflineBackup {
  static TYPE = "devdocs-offline";
  static VERSION = 1;
  static MIME_TYPE = "application/json";

  /**
   * @param {Doc[]} docs
   * @returns {string} The name to save the backup under.
   */
  filename(docs) {
    const date = new Date().toISOString().slice(0, 10);
    const name = docs.length === 1 ? docs[0].slug : "offline";
    return `devdocs-${name}-${date}.json`;
  }

  /**
   * Calls back with a Blob containing every installed doc among `docs`, and
   * the number of docs it holds. Docs that aren't installed are skipped.
   *
   * @param {Doc[]} docs
   * @param {(doc: unknown, i: number, total: number) => void} onProgress
   * @param {(blob: Blob, count: number) => void} onSuccess
   * @param {(reason: string) => void} onError
   */
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
        if (!result) {
          setTimeout(next, 0);
          return;
        }

        // Ship the index file too, so that the doc can be used on a computer
        // that never downloaded it (the app falls back to the network
        // otherwise). Asking for it by the stored mtime leaves behind one that
        // belongs to a different build.
        app.db.loadIndex(doc, result.mtime, (index) => {
          // Serialize each doc on its own instead of building one big object,
          // to avoid holding the whole backup in memory twice.
          chunks.push(
            (count++ === 0 ? "" : ",") +
              JSON.stringify(this.serializeDoc(doc, result, index)),
          );
          setTimeout(next, 0);
        });
      });
    };

    next();
  }

  /**
   * @param {Doc} doc
   * @param {{ mtime: number, data: unknown }} result The doc's stored database.
   * @param {unknown} [index] The doc's entry index, when one was cached.
   * @returns {unknown} One entry of the backup's `docs` array.
   */
  serializeDoc(doc, result, index) {
    const entry = { slug: doc.slug, mtime: result.mtime, db: result.data };
    if (index !== undefined) {
      entry.index = index;
    }
    return entry;
  }

  /**
   * Reads a backup file and stores the docs it holds.
   *
   * @param {File | null} file
   * @param {(doc: unknown, i: number, total: number) => void} onProgress
   * @param {(summary: ImportSummary) => void} onSuccess
   * @param {(reason: string, skipped?: string[]) => void} onError
   */
  import(file, onProgress, onSuccess, onError) {
    if (!file || (file.type && file.type !== OfflineBackup.MIME_TYPE)) {
      onError("invalid");
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const data = (() => {
        try {
          return JSON.parse(/** @type {string} */ (reader.result));
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

  /**
   * Stores each valid entry, one at a time.
   *
   * @param {unknown[]} entries The backup's `docs` array, not yet validated.
   * @param {(doc: unknown, i: number, total: number) => void} onProgress
   * @param {(summary: ImportSummary) => void} onSuccess
   * @param {(reason: string, skipped?: string[]) => void} onError
   */
  importDocs(entries, onProgress, onSuccess, onError) {
    const queue = [];
    const skipped = [];

    for (var entry of entries) {
      var doc = this.isValidEntry(entry) && this.findDoc(entry.slug);
      if (doc) {
        queue.push([doc, entry]);
      } else {
        const slug = /** @type {{ slug?: unknown }} */ (entry)?.slug;
        skipped.push(typeof slug === "string" ? slug : "?");
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

      app.db.store(
        doc,
        entry.db,
        mtime,
        () => {
          if (this.isValidIndex(entry.index)) {
            // Keyed by the backup's mtime so that the store discards it when
            // the doc has been updated since the backup was made.
            app.db.storeIndex(doc, mtime, entry.index);
          }
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

  /**
   * Storing a doc clears whatever was installed before it, so an entry that
   * isn't usable has to be rejected rather than wipe a working installation.
   * The index page is what DB#checkForCorruptedDocs looks for.
   *
   * @param {unknown} entry Straight out of the file.
   * @returns {entry is BackupEntry} Narrows the entry for the caller.
   */
  isValidEntry(entry) {
    // Read optimistically; the checks below are what decide whether it holds.
    const e = /** @type {BackupEntry} */ (entry);
    return (
      e != null &&
      typeof e.slug === "string" &&
      Number.isSafeInteger(e.mtime) &&
      e.mtime > 0 &&
      e.db?.constructor === Object &&
      typeof e.db.index === "string" &&
      e.db.index.length > 0
    );
  }

  /**
   * @param {unknown} index
   * @returns {index is { entries: unknown[], types: unknown[] }} Whether the
   *   entry carries a usable index file.
   */
  isValidIndex(index) {
    // Read optimistically; the checks below are what decide whether it holds.
    const i = /** @type {{ entries: unknown, types: unknown }} */ (index);
    return (
      i?.constructor === Object &&
      Array.isArray(i.entries) &&
      Array.isArray(i.types)
    );
  }

  /**
   * @param {string} slug
   * @returns {Doc | undefined} The doc, enabled or not.
   */
  findDoc(slug) {
    return (
      app.docs.findBy("slug", slug) || app.disabledDocs.findBy("slug", slug)
    );
  }

  /**
   * Enabling the docs up-front is what makes their object stores exist: the
   * schema bump triggers DB#onUpgradeNeeded, which only creates stores for the
   * enabled docs.
   *
   * @param {Doc[]} docs
   * @returns {number} How many docs weren't enabled before.
   */
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
}
