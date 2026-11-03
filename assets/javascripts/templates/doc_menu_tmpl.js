// @ts-check

import { $ } from "../lib/util.js";
/** @import { Doc } from "../models/doc.js" */
/** @import { Entry } from "../models/entry.js" */
/** @import { Type } from "../models/type.js" */

const arrow = '<svg class="_doc-menu-arrow"><use xlink:href="#icon-dir"/></svg>';

/**
 * The opened doc's contents menu, at the top left of the page: the button
 * that opens it, and the panel. Filled in by views/layout/doc_menu.js.
 */
export const docMenu = `\
<button type="button" class="_doc-menu-btn" aria-haspopup="true" aria-expanded="false"><span class="_doc-menu-icon"></span><span class="_doc-menu-name"></span><svg class="_doc-menu-caret"><use xlink:href="#icon-dir"/></svg></button>
<div class="_doc-menu-panel" hidden>
  <div class="_doc-menu-head">
    <a class="_doc-menu-title"></a>
    <form class="_doc-menu-search" role="search">
      <svg><use xlink:href="#icon-search"/></svg>
      <input type="search" class="_doc-menu-input" placeholder="Search these docs&hellip;" autocomplete="off" autocapitalize="off" autocorrect="off" spellcheck="false" maxlength="50" aria-label="Search this doc">
    </form>
  </div>
  <div class="_doc-menu-list"></div>
</div>\
`;

/**
 * The doc's contents: its types, each opening to list its entries.
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
      (type, index) => `\
<div class="_doc-menu-type">
  <button type="button" class="_doc-menu-row" data-type-index="${index}" aria-expanded="false">${arrow}<span>${$.escape(type.name)}</span><small>${type.count}</small></button>
  <div class="_doc-menu-entries" hidden></div>
</div>`,
    )
    .join("");
};

/**
 * A link to one entry. Given a list, the template renderer draws one each.
 *
 * @param {Entry} entry
 * @returns {string}
 */
export const docMenuEntry = (entry) =>
  `<a href="${entry.fullPath()}" class="_doc-menu-link">${$.escape(entry.name)}</a>`;

/**
 * Entries matching the search in the doc.
 *
 * @param {Doc} doc
 * @param {Entry[]} entries
 * @returns {string}
 */
export const docMenuResults = (doc, entries) =>
  entries.length === 0
    ? `<p class="_doc-menu-empty">Nothing in ${$.escape(doc.fullName)} matches.</p>`
    : entries.map(docMenuEntry).join("");
