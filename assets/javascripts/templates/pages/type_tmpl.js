// @ts-check

/**
 * A type's page: every entry of that type in the doc.
 *
 * @param {any} type
 * @returns {string}
 */
app.templates.typePage = (type) => {
  return ` <h1>${type.doc.fullName} / ${type.name}</h1>
<ul class="_entry-list">${app.templates.render(
    "typePageEntry",
    type.entries(),
  )}</ul> `;
};

/**
 * One row of a type page.
 *
 * @param {any} entry
 * @returns {string}
 */
app.templates.typePageEntry = (entry) => {
  return `<li><a href="${entry.fullPath()}">${$.escape(entry.name)}</a></li>`;
};
