// @ts-check

// A type's own properties are declared in globals.d.ts, for the reason given
// in models/doc.js.

import { Entry } from "./entry.js";
import { Model } from "./model.js";

/** A group of entries within a doc, e.g. "Methods". */
export class Type extends Model {

  /** @returns {string} The app path for the type's page. */
  fullPath() {
    return `/${this.doc.slug}-${this.slug}/`;
  }

  /** @returns {Entry[]} Every entry of this type in the doc. */
  entries() {
    return this.doc.entries.findAllBy("type", this.name);
  }

  /** @returns {Entry} An entry standing for the type's page, so that it can be searched for. */
  toEntry() {
    return new Entry({
      doc: this.doc,
      name: `${this.doc.name} / ${this.name}`,
      path: ".." + this.fullPath(),
    });
  }
}
