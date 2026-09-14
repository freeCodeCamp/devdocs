// @ts-check

import { View } from "../view.js";
/** @import { Context } from "../../lib/page.js" */

/** The app's own pages — About, News, the user guide and the 404. */
export class StaticPage extends View {
  static className = "_static";

  static titles = {
    about: "About",
    news: "News",
    help: "User Guide",
    notFound: "404",
  };

  /** Also forgets which page was shown. */
  deactivate() {
    if (super.deactivate()) {
      this.empty();
      this.page = null;
    }
  }

  /** @param {string} page One of the keys of `titles`. */
  render(page) {
    this.page = page;
    this.html(this.tmpl(`${this.page}Page`));
  }

  /** @returns {string} */
  getTitle() {
    return this.statics().titles[this.page];
  }

  /** @param {Context} context */
  onRoute(context) {
    this.render(context.page || "notFound");
  }
}
