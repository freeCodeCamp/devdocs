// @ts-check

/** A type's page: every entry of that type in the doc. */
app.views.TypePage = class TypePage extends app.View {
  static className = "_page";

  deactivate() {
    if (super.deactivate()) {
      this.empty();
      this.type = null;
    }
  }

  /** @param {any} type */
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
};
