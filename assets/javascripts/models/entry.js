// @ts-check

//= require app/searcher

/**
 * One searchable page, or a heading within one.
 *
 * Attributes, from the doc's index: `name`, `type`, `path`. The constructor
 * derives `text`, the normalized string the searcher matches against, and the
 * doc sets `doc` when it builds its entries.
 */
class Entry extends Model {
  /**
   * Expands a searchable string with its alias, if it has one, so that both
   * spellings match.
   *
   * @param {string} string
   * @returns {string | string[]} Both spellings when an alias applies,
   *   otherwise the string unchanged.
   */
  static applyAliases(string) {
    const aliases = app.config.docs_aliases;
    if (aliases.hasOwnProperty(string)) {
      return [string, aliases[string]];
    } else {
      const words = string.split(".");
      for (let i = 0; i < words.length; i++) {
        var word = words[i];
        if (aliases.hasOwnProperty(word)) {
          words[i] = aliases[word];
          return [string, words.join(".")];
        }
      }
    }
    return string;
  }

  /** @param {Record<string, unknown>} [attributes] Copied onto the entry by Model. */
  constructor(attributes) {
    super(attributes);
    this.text = Entry.applyAliases(app.Searcher.normalizeString(this.name));
  }

  /**
   * Makes the entry findable under another name as well.
   *
   * @param {string} name
   */
  addAlias(name) {
    const text = Entry.applyAliases(app.Searcher.normalizeString(name));
    if (!Array.isArray(this.text)) {
      this.text = [this.text];
    }
    // applyAliases returns both the name and its alias; keeping only the alias
    // would make the name of an aliased doc (e.g. Julia) unsearchable.
    this.text.push(...(Array.isArray(text) ? text : [text]));
  }

  /** @returns {string} The app path for the entry's page. */
  fullPath() {
    return this.doc.fullPath(this.isIndex() ? "" : this.path);
  }

  /** @returns {string} The path the page is stored under offline, without the hash. */
  dbPath() {
    return this.path.replace(/#.*/, "");
  }

  /** @returns {string} The app path of the entry's HTML file. */
  filePath() {
    return this.doc.fullPath(this._filePath());
  }

  /** @returns {string} Where the entry's HTML is served from. */
  fileUrl() {
    return this.doc.fileUrl(this._filePath());
  }

  /** @returns {string} The entry's path as a `.html` filename, without the hash. */
  _filePath() {
    let result = this.path.replace(/#.*/, "");
    if (result.slice(-5) !== ".html") {
      result += ".html";
    }
    return result;
  }

  /** @returns {boolean} Whether the entry stands for the doc itself. */
  isIndex() {
    return this.path === "index";
  }

  /** @returns {unknown} The entry's type, or `undefined`. */
  getType() {
    return this.doc.types.findBy("name", this.type);
  }

  /**
   * Reads the entry's page out of the offline database.
   *
   * @param {(html: string) => void} onSuccess
   * @param {() => void} onError
   */
  loadFile(onSuccess, onError) {
    return app.db.load(this, onSuccess, onError);
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.models.Entry = Entry;
