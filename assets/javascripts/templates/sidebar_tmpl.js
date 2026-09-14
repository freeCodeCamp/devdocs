// @ts-check

import { app } from "../app/app.js";
import { $ } from "../lib/util.js";
/** @import { Doc } from "../models/doc.js" */
/** @import { Entry } from "../models/entry.js" */
/** @import { Type } from "../models/type.js" */

/**
 * How a sidebar row is rendered.
 *
 * @typedef {object} SidebarOptions
 * @property {boolean} [disabled] Render the doc as disabled, with an Enable button.
 * @property {boolean} [fullName] Include the version in the doc's name.
 * @property {boolean} [checked] Tick the row's checkbox.
 * @property {boolean} [open] Render a versioned doc expanded.
 * @property {number} [count] How many docs the heading covers.
 */

/** The disclosure triangle shown on a sidebar row that can be expanded. */
const arrow = '<svg class="_list-arrow"><use xlink:href="#icon-dir"/></svg>';

/**
 * A doc's row in the sidebar.
 *
 * @param {Doc} doc
 * @param {SidebarOptions} [options]
 * @returns {string}
 */
export const sidebarDoc = function (doc, options) {
  if (options == null) {
    options = {};
  }
  let link = `<a href="${doc.fullPath()}" class="_list-item _icon-${doc.icon} `;
  link += options.disabled ? "_list-disabled" : "_list-dir";
  link += `" data-slug="${doc.slug}" title="${doc.fullName}" tabindex="-1">`;
  if (options.disabled) {
    link += `<span class="_list-enable" data-enable="${doc.slug}">Enable</span>`;
  } else {
    link += arrow;
  }
  if (doc.release) {
    link += `<span class="_list-count">${doc.release}</span>`;
  }
  link += `<span class="_list-text">${doc.name}`;
  if (options.fullName || (options.disabled && doc.version)) {
    link += ` ${doc.version}`;
  }
  return link + "</span></a>";
};

/**
 * A type's row, with the number of entries it holds.
 *
 * @param {Type} type
 * @returns {string}
 */
export const sidebarType = (type) =>
  `<a href="${type.fullPath()}" class="_list-item _list-dir" data-slug="${
    type.slug
  }" tabindex="-1">${arrow}<span class="_list-count">${
    type.count
  }</span><span class="_list-text">${$.escape(type.name)}</span></a>`;

/**
 * An entry's row.
 *
 * @param {Entry} entry
 * @returns {string}
 */
export const sidebarEntry = (entry) =>
  `<a href="${entry.fullPath()}" class="_list-item _list-hover" tabindex="-1">${$.escape(
    entry.name,
  )}</a>`;

/**
 * A search result: like an entry's row, plus the doc it belongs to and a way
 * to reveal it in the list or enable its doc.
 *
 * @param {Entry} entry
 * @returns {string}
 */
export const sidebarResult = function (entry) {
  let addons =
    entry.isIndex() && app.disabledDocs.contains(entry.doc)
      ? `<span class="_list-enable" data-enable="${entry.doc.slug}">Enable</span>`
      : '<span class="_list-reveal" data-reset-list title="Reveal in list"></span>';
  if (entry.doc.version && !entry.isIndex()) {
    addons += `<span class="_list-count">${entry.doc.short_version}</span>`;
  }
  return `<a href="${entry.fullPath()}" class="_list-item _list-hover _list-result _icon-${
    entry.doc.icon
  }" tabindex="-1">${addons}<span class="_list-text">${$.escape(
    entry.name,
  )}</span></a>`;
};

/**
 * Shown when a search matched nothing, with a pointer to the preferences
 * when some docs are disabled.
 *
 * @returns {string}
 */
export const sidebarNoResults = function () {
  let html = ' <div class="_list-note">No results.</div> ';
  if (!app.isSingleDoc() && !app.disabledDocs.isEmpty()) {
    html += `\
<div class="_list-note">Note: documentations must be <a href="/settings" class="_list-note-link">enabled</a> to appear in the search.</div>\
`;
  }
  return html;
};

/**
 * The row that loads the next page of a long list.
 *
 * @param {number} count How many entries are left.
 * @returns {string}
 */
export const sidebarPageLink = (count) =>
  `<span role="link" class="_list-item _list-pagelink">Show more\u2026 (${count})</span>`;

/**
 * A doc's row in the picker, with a checkbox.
 *
 * @param {Doc} doc
 * @param {SidebarOptions} [options]
 * @returns {string}
 */
export const sidebarLabel = function (doc, options) {
  if (options == null) {
    options = {};
  }
  let label = '<label class="_list-item';
  if (!doc.version) {
    label += ` _icon-${doc.icon}`;
  }
  label += `"><input type="checkbox" name="${doc.slug}" class="_list-checkbox" `;
  if (options.checked) {
    label += "checked";
  }
  return label + `><span class="_list-text">${doc.fullName}</span></label>`;
};

/**
 * A doc that has several versions, as an expandable row.
 *
 * @param {Doc} doc
 * @param {string} versions The rendered rows for each version.
 * @param {SidebarOptions} [options]
 * @returns {string}
 */
export const sidebarVersionedDoc = function (doc, versions, options) {
  if (options == null) {
    options = {};
  }
  let html = `<div class="_list-item _list-dir _list-rdir _icon-${doc.icon}`;
  if (options.open) {
    html += " open";
  }
  return (
    html +
    `" tabindex="0">${arrow}${doc.name}</div><div class="_list _list-sub">${versions}</div>`
  );
};

/**
 * The heading above the disabled docs.
 *
 * @param {SidebarOptions} options
 * @returns {string}
 */
export const sidebarDisabled = (options) =>
  `<h6 class="_list-title">${arrow}Disabled (${options.count}) <a href="/settings" class="_list-title-link" tabindex="-1">Customize</a></h6>`;

/**
 * @param {string} html The rendered disabled docs.
 * @returns {string}
 */
export const sidebarDisabledList = (html) =>
  `<div class="_disabled-list">${html}</div>`;

/**
 * A disabled doc that has several versions.
 *
 * @param {Doc} doc
 * @param {string} versions The rendered rows for each version.
 * @returns {string}
 */
export const sidebarDisabledVersionedDoc = (doc, versions) =>
  `<a class="_list-item _list-dir _icon-${doc.icon} _list-disabled" data-slug="${doc.slug_without_version}" tabindex="-1">${arrow}${doc.name}</a><div class="_list _list-sub">${versions}</div>`;

export const docPickerHeader =
  '<div class="_list-picker-head"><span>Documentation</span> <span>Enable</span></div>';

export const docPickerNote = `\
<div class="_list-note">Tip: for faster and better search results, select only the docs you need.</div>
<a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank" rel="noopener">Vote for new documentation</a>\
`;
