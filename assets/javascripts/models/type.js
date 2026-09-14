// @ts-check

/**
 * A group of entries within a doc, e.g. "Methods".
 *
 * Attributes, from the doc's index: `name`, `slug`, `count`. The doc sets
 * `doc` when it builds its types.
 */
app.models.Type = class Type extends app.Model {

  /** @returns {string} The app path for the type's page. */
  fullPath() {
    return `/${this.doc.slug}-${this.slug}/`;
  }

  /** @returns {unknown[]} Every entry of this type in the doc. */
  entries() {
    return this.doc.entries.findAllBy("type", this.name);
  }

  /** @returns {unknown} An entry standing for the type's page, so that it can be searched for. */
  toEntry() {
    return new app.models.Entry({
      doc: this.doc,
      name: `${this.doc.name} / ${this.name}`,
      path: ".." + this.fullPath(),
    });
  }
};
