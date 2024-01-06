// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const arrow = '<svg class="_path-arrow"><use xlink:href="#icon-dir"/></svg>';

app.templates.path = function (doc, type, entry) {
  let html = `<a href="${doc.fullPath()}" class="_path-item _icon-${
    doc.icon
  }">${doc.fullName}</a>`;
  if (type) {
    html += `${arrow}<a href="${type.fullPath()}" class="_path-item">${
      type.name
    }</a>`;
  }
  if (entry) {
    html += `${arrow}<span class="_path-item">${$.escape(entry.name)}</span>`;
  }
  return html;
};
