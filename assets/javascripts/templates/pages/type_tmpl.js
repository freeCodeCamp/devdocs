// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.templates.typePage = type => ` <h1>${type.doc.fullName} / ${type.name}</h1>
<ul class="_entry-list">${app.templates.render('typePageEntry', type.entries())}</ul> `;

app.templates.typePageEntry = entry => `<li><a href="${entry.fullPath()}">${$.escape(entry.name)}</a></li>`;
