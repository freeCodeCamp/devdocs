// @ts-check

import { ajax } from "../lib/ajax.js";
import {
  DocPackError,
  MANIFEST_FILENAME,
  packDocs,
  packUrl,
  readManifest,
} from "../lib/doc_packs.js";
/** @import { StoredPack } from "../lib/doc_packs.js" */
/** @import { LocalStorageStore } from "../lib/local_storage_store.js" */

/**
 * The doc packs this person has added (see lib/doc_packs.js), kept in their
 * browser's local storage with each pack's manifest, so that the app can list
 * the packs' docs at boot without waiting on the network.
 */
export class DocPacks {
  static STORAGE_KEY = "docPacks";

  /** How long a downloaded manifest is used before it's downloaded again. */
  static REFRESH_INTERVAL = 24 * 60 * 60 * 1000;

  /** @param {LocalStorageStore} store */
  constructor(store) {
    this.store = store;
  }

  /** @returns {StoredPack[]} */
  all() {
    const packs = this.store.get(DocPacks.STORAGE_KEY);
    return Array.isArray(packs)
      ? packs.filter((pack) => pack && typeof pack.url === "string" && Array.isArray(pack.docs))
      : [];
  }

  /** @returns {Record<string, unknown>[]} Every pack's docs, as manifest attributes. */
  docs() {
    return this.all().flatMap(packDocs);
  }

  /**
   * Downloads a pack's manifest and adds the pack.
   *
   * @param {string} input What the person typed or pasted.
   * @param {(error: DocPackError | null, pack?: StoredPack) => void} callback
   */
  add(input, callback) {
    const url = packUrl(input);
    if (!url) {
      const insecure = /^\s*http:\/\//i.test(input);
      callback(
        insecure
          ? new DocPackError(
              "The address has to start with https://, so that nobody can change the pack on its way to you.",
              "insecure",
            )
          : new DocPackError(
              "That isn't a web address. Paste a link such as github.com/someone/their-docs.",
              "address",
            ),
      );
      return;
    }
    if (this.all().some((pack) => pack.url === url)) {
      callback(new DocPackError("That pack is already added.", "duplicate"));
      return;
    }

    this.fetch(url, (error, pack) => {
      if (error) {
        callback(error);
        return;
      }
      if (!this.save([...this.all(), pack])) {
        callback(
          new DocPackError(
            "The pack couldn't be saved, because this browser blocks local storage for DevDocs.",
            "storage",
          ),
        );
        return;
      }
      callback(null, pack);
    });
  }

  /**
   * @param {string} url
   * @returns {StoredPack | undefined} The pack that was removed.
   */
  remove(url) {
    const packs = this.all();
    const pack = packs.find((pack) => pack.url === url);
    if (pack) {
      this.save(packs.filter((other) => other !== pack));
    }
    return pack;
  }

  /**
   * Downloads again the manifests that are older than a day, in the
   * background. Changes take effect the next time the app loads, like updates
   * to the built-in docs.
   */
  refresh() {
    for (const pack of this.all()) {
      if (Date.now() - (pack.fetchedAt || 0) < DocPacks.REFRESH_INTERVAL) {
        continue;
      }
      this.fetch(pack.url, (error, fresh) => {
        if (error) {
          return;
        }
        // Read again: the list may have changed while the request ran.
        this.save(
          this.all().map((other) => (other.url === pack.url ? fresh : other)),
        );
      });
    }
  }

  /**
   * @param {string} url A URL returned by `packUrl`.
   * @param {(error: DocPackError | null, pack?: StoredPack) => void} callback
   */
  fetch(url, callback) {
    const manifestUrl = url + MANIFEST_FILENAME;
    ajax({
      url: manifestUrl,
      dataType: "json",
      success: (json) => {
        let pack;
        try {
          pack = readManifest(json, url);
        } catch (error) {
          callback(error);
          return;
        }
        pack.fetchedAt = Date.now();
        callback(null, pack);
      },
      error: (type, xhr) => {
        if (type === "invalid") {
          callback(new DocPackError(`${manifestUrl} isn't valid JSON.`, "invalid"));
        } else if (xhr?.status === 404) {
          callback(new DocPackError(`There's no ${MANIFEST_FILENAME} at ${url}.`, "missing"));
        } else {
          // Status 0: the site is down, or doesn't let other sites read it
          // (most websites), which the browser doesn't tell apart.
          callback(new DocPackError(`Couldn't download ${manifestUrl}.`, "unreachable"));
        }
      },
    });
  }

  /**
   * @param {StoredPack[]} packs
   * @returns {boolean} Whether the packs were stored.
   */
  save(packs) {
    return !!this.store.set(DocPacks.STORAGE_KEY, packs);
  }
}
