// @ts-check

import { config } from "../app/config.js";
/** @import { Doc } from "../models/doc.js" */

/**
 * The notices shown above the content: a bar of explanatory text.
 *
 * @param {string} text
 * @returns {string}
 */
const notice = (text) => `<p class="_notice-text">${text}</p>`;

/** @param {Doc} doc @returns {string} */
export const singleDocNotice = (doc) =>
  notice(` You're browsing the ${doc.fullName} documentation. To browse all docs, go to
<a href="//${config.production_host}" target="_top">${config.production_host}</a> (or press <code>esc</code>). `);

export const disabledDocNotice = () =>
  notice(` <strong>This documentation is disabled.</strong>
To enable it, go to <a href="/settings" class="_notice-link">Preferences</a>. `);

export const noOriginalLinkNotice = () =>
  notice(` The original page link is not available for this documentation. `);

export const copyFailedNotice = () =>
  notice(` Couldn't copy the original page link to the clipboard. `);
