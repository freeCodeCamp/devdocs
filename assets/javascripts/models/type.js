// @ts-check

/**
 * A group of entries within a doc, e.g. "Methods".
 *
 * Attributes, from the doc's index: `name`, `slug`, `count`. The doc sets
 * `doc` when it builds its types.
 */
class Type extends Model {

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
    return new app.models.Entry({
      doc: this.doc,
      name: `${this.doc.name} / ${this.name}`,
      path: ".." + this.fullPath(),
    });
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.models.Type = Type;
