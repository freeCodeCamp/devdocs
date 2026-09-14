// @ts-check

import { setFaviconForDoc } from "../../lib/favicon.js";
import { View } from "../view.js";
/** @import { Context } from "../../lib/page.js" */
/** @import { Type } from "../../models/type.js" */

/** A type's page: every entry of that type in the doc. */
export class TypePage extends View {
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

  /** @param {Context} context */
  onRoute(context) {
    this.render(context.type);
  }
}
