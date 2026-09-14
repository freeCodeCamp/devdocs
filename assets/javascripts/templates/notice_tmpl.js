// @ts-check

/**
 * The notices shown above the content: a bar of explanatory text.
 *
 * @param {string} text
 * @returns {string}
 */
const notice = (text) => `<p class="_notice-text">${text}</p>`;

/** @param {Doc} doc @returns {string} */
app.templates.singleDocNotice = (doc) =>
  notice(` You're browsing the ${doc.fullName} documentation. To browse all docs, go to
<a href="//${app.config.production_host}" target="_top">${app.config.production_host}</a> (or press <code>esc</code>). `);

app.templates.disabledDocNotice = () =>
  notice(` <strong>This documentation is disabled.</strong>
To enable it, go to <a href="/settings" class="_notice-link">Preferences</a>. `);

app.templates.noOriginalLinkNotice = () =>
  notice(` The original page link is not available for this documentation. `);

app.templates.copyFailedNotice = () =>
  notice(` Couldn't copy the original page link to the clipboard. `);
