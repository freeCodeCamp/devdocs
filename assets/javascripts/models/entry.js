//= require app/searcher

app.models.Entry = class Entry extends app.Model {
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

  // Attributes: name, type, path
  constructor() {
    super(...arguments);
    this.text = Entry.applyAliases(app.Searcher.normalizeString(this.name));
  }

  addAlias(name) {
    const text = Entry.applyAliases(app.Searcher.normalizeString(name));
    if (!Array.isArray(this.text)) {
      this.text = [this.text];
    }
    this.text.push(Array.isArray(text) ? text[1] : text);
  }

  fullPath() {
    return this.doc.fullPath(this.isIndex() ? "" : this.path);
  }

  dbPath() {
    return this.path.replace(/#.*/, "");
  }

  filePath() {
    return this.doc.fullPath(this._filePath());
  }

  fileUrl() {
    return this.doc.fileUrl(this._filePath());
  }

  _filePath() {
    let result = this.path.replace(/#.*/, "");
    if (result.slice(-5) !== ".html") {
      result += ".html";
    }
    return result;
  }

  isIndex() {
    return this.path === "index";
  }

  getType() {
    return this.doc.types.findBy("name", this.type);
  }

  loadFile(onSuccess, onError) {
    return app.db.load(this, onSuccess, onError);
  }
};
