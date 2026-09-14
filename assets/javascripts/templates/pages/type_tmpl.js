// @ts-check

import { $ } from "../../lib/util.js";
import { render } from "../base.js";
/** @import { Entry } from "../../models/entry.js" */
/** @import { Type } from "../../models/type.js" */

/**
 * A type's page: every entry of that type in the doc.
 *
 * @param {Type} type
 * @returns {string}
 */
export const typePage = (type) => {
  return ` <h1>${type.doc.fullName} / ${type.name}</h1>
<ul class="_entry-list">${render(
    "typePageEntry",
    type.entries(),
  )}</ul> `;
};

/**
 * One row of a type page.
 *
 * @param {Entry} entry
 * @returns {string}
 */
export const typePageEntry = (entry) => {
  return `<li><a href="${entry.fullPath()}">${$.escape(entry.name)}</a></li>`;
};
