// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.views.StaticPage = class StaticPage extends app.View {
  static initClass() {
    this.className = "_static";

    this.titles = {
      about: "About",
      news: "News",
      help: "User Guide",
      notFound: "404",
    };
  }

  deactivate() {
    if (super.deactivate(...arguments)) {
      this.empty();
      this.page = null;
    }
  }

  render(page) {
    this.page = page;
    this.html(this.tmpl(`${this.page}Page`));
  }

  getTitle() {
    return this.constructor.titles[this.page];
  }

  onRoute(context) {
    this.render(context.page || "notFound");
  }
};
app.views.StaticPage.initClass();
