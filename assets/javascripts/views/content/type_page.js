// @ts-check

/** A type's page: every entry of that type in the doc. */
class TypePage extends app.View {
  static className = "_page";

  /** Also forgets which type was shown. */
  deactivate() {
    if (super.deactivate()) {
      this.empty();
      this.type = null;
    }
  }

  /** @param {Type} type */
  render(type) {
    this.type = type;
    this.html(this.tmpl("typePage", this.type));
    setFaviconForDoc(this.type.doc);
  }

  /** @returns {string} */
  getTitle() {
    return `${this.type.doc.fullName} / ${this.type.name}`;
  }

  /** @param {any} context */
  onRoute(context) {
    this.render(context.type);
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.TypePage = TypePage;
