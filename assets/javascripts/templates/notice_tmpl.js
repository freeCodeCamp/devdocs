// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const notice = text => `<p class="_notice-text">${text}</p>`;

app.templates.singleDocNotice = doc => notice(` You're browsing the ${doc.fullName} documentation. To browse all docs, go to
<a href="//${app.config.production_host}" target="_top">${app.config.production_host}</a> (or press <code>esc</code>). `
);

app.templates.disabledDocNotice = () => notice(` <strong>This documentation is disabled.</strong>
To enable it, go to <a href="/settings" class="_notice-link">Preferences</a>. `
);
