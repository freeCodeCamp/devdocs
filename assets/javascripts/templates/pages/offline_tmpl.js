app.templates.offlinePage = (docs, hasPersistence, isPersistent) => `\
<h1 class="_lined-heading">Offline Documentation</h1>

<div class="_docs-tools">
  <label>
    <input type="checkbox" name="autoUpdate" value="1" ${
      app.settings.get("manualUpdate") ? "" : "checked"
    }>Install updates automatically
  </label>
  <div class="_docs-links">
    <button type="button" class="_btn-link" data-action-all="install" title="Download every enabled documentation for offline use">Install all</button><button type="button" class="_btn-link" data-action-all="update" title="Download the current version of every outdated documentation"><strong>Update all</strong></button><button type="button" class="_btn-link" data-action-all="uninstall" title="Delete the offline data of every installed documentation">Uninstall all</button><button type="button" class="_btn-link _show" data-export-docs title="Save the installed documentations to a file, to restore them later or on another computer">Export all</button><label class="_btn-link _file-btn _show" title="Restore documentations from a previously exported file">Import<input type="file" name="importDocs" accept="application/json,.json"></label>
  </div>
</div>

<div class="_table">
  <table class="_docs">
    <tr>
      <th>Documentation</th>
      <th class="_docs-size">Size</th>
      <th>Status</th>
      <th>Action</th>
    </tr>
    ${docs}
  </table>
</div>
<div id="_offline-backup-status"></div>
<div id="_offline-persistence-note">
  ${offlinePersistenceNote(hasPersistence, isPersistent)}
</div>
<h2 class="_block-heading">Questions & Answers</h2>
<dl>
  <dt>How does this work?
  <dd>Each page is cached as a key-value pair in <a href="https://devdocs.io/dom/indexeddb_api">IndexedDB</a> (downloaded from a single file).<br>
      The app also uses <a href="https://devdocs.io/dom/service_worker_api/using_service_workers">Service Workers</a> and <a href="https://devdocs.io/dom/web_storage_api">localStorage</a> to cache the assets and index files.
  <dt>Can I close the tab/browser?
  <dd>${canICloseTheTab()}
  <dt>How do I move the documentations to another computer?
  <dd>Export them to a file using the buttons above, copy it over, and import it there. The other computer still needs to load DevDocs once while online for the app itself to be cached.
  <dt>What if I don't update a documentation?
  <dd>You'll see outdated content and some pages will be missing or broken, because the rest of the app (including data for the search and sidebar) uses a different caching mechanism that's updated automatically.
  <dt>I found a bug, where do I report it?
  <dd>In the <a href="https://github.com/freeCodeCamp/devdocs/issues">issue tracker</a>. Thanks!
  <dt>How do I uninstall/reset the app?
  <dd>Click <a href="#" data-behavior="reset">here</a>.
  <dt>Why aren't all documentations listed above?
  <dd>You have to <a href="/settings">enable</a> them first.
</dl>\
`;

app.templates.backupProgress = (action, doc, i, total) =>
  `${action} ${doc.fullName}\u2026 (${i}/${total})`;

app.templates.backupExported = (count) =>
  `Exported ${count} ${pluralizeDocs(count)}.`;

app.templates.backupImported = function (result) {
  let html = `<strong>Imported ${result.docs.length} ${pluralizeDocs(
    result.docs.length
  )}.</strong>`;

  if (result.failed.length > 0) {
    html += ` Couldn't be stored: ${result.failed.join(", ")}.`;
  }
  if (result.skipped.length > 0) {
    html += ` Not available anymore: ${result.skipped.join(", ")}.`;
  }
  if (result.enabled > 0) {
    html += " Reloading\u2026";
  }

  return html;
};

app.templates.backupError = function (reason) {
  switch (reason) {
    case "empty":
      return "<strong>No documentation is installed.</strong> Install one before exporting.";
    case "unknown":
      return "<strong>Nothing to import.</strong> This file doesn't contain any documentation that DevDocs still offers.";
    case "version":
      return "<strong>This file was exported by a newer version of DevDocs.</strong> Reload the app and try again.";
    default:
      return "<strong>The file you selected is invalid.</strong> Only files exported from this page can be imported.";
  }
};

var pluralizeDocs = (count) =>
  count === 1 ? "documentation" : "documentations";

app.templates.persistenceError = function (exception) {
  const reason = exception
    ? `<code class="_label">${exception.name}: ${exception.message}</code>`
    : "Bookmark this site and try again.";

  return `<p class="_note _note-red"><strong>Persistent storage was denied by your browser.</strong> ${reason}`;
};

var offlinePersistenceNote = function (hasPersistence, isPersistent) {
  if (isPersistent) {
    return "";
  }

  let html =
    "<p class=\"_note\"><strong>Note:</strong> your browser may delete DevDocs's offline data if your computer is running low on disk space and you haven't used the app in a while.";

  if (hasPersistence) {
    html +=
      ' <button type="button" class="_btn-link _bold" data-enable-persistence>Enable persistent storage</button>.';
  } else {
    html +=
      " Load this page before going offline to make sure the data is still there.";
  }

  return html;
};

var canICloseTheTab = function () {
  if (app.ServiceWorker.isEnabled()) {
    return ' Yes! Even offline, you can open a new tab, go to <a href="//devdocs.io">devdocs.io</a>, and everything will work as if you were online (provided you installed all the documentations you want to use beforehand). ';
  } else {
    let reason = "aren't available in your browser (or are disabled)";

    if (app.config.env !== "production") {
      reason =
        "are disabled in your development instance of DevDocs (enable them by setting the <code>ENABLE_SERVICE_WORKER</code> environment variable to <code>true</code>)";
    }

    return ` No. Service Workers ${reason}, so loading <a href="//devdocs.io">devdocs.io</a> offline won't work.<br>
The current tab will continue to function even when you go offline (provided you installed all the documentations beforehand). `;
  }
};

app.templates.offlineDoc = function (doc, status) {
  const outdated = doc.isOutdated(status);

  let html = `\
<tr data-slug="${doc.slug}"${outdated ? ' class="_highlight"' : ""}>
  <td class="_docs-name _icon-${doc.icon}">${doc.fullName}</td>
  <td class="_docs-size">${
    Math.ceil(doc.db_size / 100000) / 10
  }&nbsp;<small>MB</small></td>\
`;

  html += !(status && status.installed)
    ? `\
<td>-</td>
<td><button type="button" class="_btn-link" data-action="install">Install</button></td>\
`
    : outdated
      ? `\
<td><strong>Outdated</strong></td>
<td><button type="button" class="_btn-link _bold" data-action="update">Update</button> &bull; <button type="button" class="_btn-link" data-action="uninstall">Uninstall</button> &bull; <button type="button" class="_btn-link" data-action="export">Export</button></td>\
`
      : `\
<td>Up&#8209;to&#8209;date</td>
<td><button type="button" class="_btn-link" data-action="uninstall">Uninstall</button> &bull; <button type="button" class="_btn-link" data-action="export">Export</button></td>\
`;

  return html + "</tr>";
};
