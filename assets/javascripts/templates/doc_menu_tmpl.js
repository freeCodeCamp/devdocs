// @ts-check

import { $ } from "../lib/util.js";
/** @import { Doc } from "../models/doc.js" */
/** @import { Entry } from "../models/entry.js" */
/** @import { Type } from "../models/type.js" */

/**
 * The opened doc's button in the header, and the panel it opens. Filled in by
 * views/layout/doc_menu.js.
 */
export const docMenu = `\
<button type="button" class="_header-btn _doc-menu-btn" aria-haspopup="true" aria-expanded="false" hidden><span class="_doc-menu-icon"></span></button>
<div class="_doc-menu-panel" hidden>
  <div class="_doc-menu-head">
    <a class="_doc-menu-title"></a>
    <form class="_doc-menu-search" role="search">
      <svg><use xlink:href="#icon-search"/></svg>
      <input type="search" class="_doc-menu-input" placeholder="Search these docs&hellip;" autocomplete="off" autocapitalize="off" autocorrect="off" spellcheck="false" maxlength="50" aria-label="Search this doc">
    </form>
  </div>
  <div class="_doc-menu-list" role="list"></div>
</div>\
`;

/**
 * The doc's contents: its types, linking to their pages.
 *
 * @param {Doc} doc
 * @param {Type[]} types
 * @returns {string}
 */
export const docMenuTypes = (doc, types) => {
  if (types.length === 0) {
    return `<p class="_doc-menu-empty">${$.escape(doc.fullName)} has no sections. Search it with the box above.</p>`;
  }
  return types
    .map(
      (type) =>
        `<a href="${type.fullPath()}" class="_doc-menu-link" role="listitem">${$.escape(type.name)}<small>${type.count}</small></a>`,
    )
    .join("");
};

/**
 * Entries matching the search in the doc.
 *
 * @param {Doc} doc
 * @param {Entry[]} entries
 * @returns {string}
 */
export const docMenuResults = (doc, entries) => {
  if (entries.length === 0) {
    return `<p class="_doc-menu-empty">Nothing in ${$.escape(doc.fullName)} matches.</p>`;
  }
  return entries
    .map(
      (entry) =>
        `<a href="${entry.fullPath()}" class="_doc-menu-link" role="listitem">${$.escape(entry.name)}</a>`,
    )
    .join("");
};
