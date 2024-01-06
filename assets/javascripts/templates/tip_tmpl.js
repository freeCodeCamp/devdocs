// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
app.templates.tipKeyNav = () => `\
<p class="_notif-text">
  <strong>ProTip</strong>
  <span class="_notif-info">(click to dismiss)</span>
<p class="_notif-text">
  Hit ${app.settings.get('arrowScroll') ? '<code class="_label">shift</code> +' : ''} <code class="_label">&darr;</code> <code class="_label">&uarr;</code> <code class="_label">&larr;</code> <code class="_label">&rarr;</code> to navigate the sidebar.<br>
  Hit <code class="_label">space / shift space</code>${app.settings.get('arrowScroll') ? ' or <code class="_label">&darr;/&uarr;</code>' : ', <code class="_label">alt &darr;/&uarr;</code> or <code class="_label">shift &darr;/&uarr;</code>'} to scroll the page.
<p class="_notif-text">
  <a href="/help#shortcuts" class="_notif-link">See all keyboard shortcuts</a>\
`;
