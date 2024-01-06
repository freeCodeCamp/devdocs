app.views.StaticPage = class StaticPage extends app.View {
  static className = "_static";

  static titles = {
    about: "About",
    news: "News",
    help: "User Guide",
    notFound: "404",
  };

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
