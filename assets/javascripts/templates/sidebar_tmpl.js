const { templates } = app;

const arrow = '<svg class="_list-arrow"><use xlink:href="#icon-dir"/></svg>';

templates.sidebarDoc = function (doc, options) {
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

templates.sidebarType = (type) =>
  `<a href="${type.fullPath()}" class="_list-item _list-dir" data-slug="${
    type.slug
  }" tabindex="-1">${arrow}<span class="_list-count">${
    type.count
  }</span><span class="_list-text">${$.escape(type.name)}</span></a>`;

templates.sidebarEntry = (entry) =>
  `<a href="${entry.fullPath()}" class="_list-item _list-hover" tabindex="-1">${$.escape(
    entry.name,
  )}</a>`;

templates.sidebarResult = function (entry) {
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

templates.sidebarNoResults = function () {
  let html = ' <div class="_list-note">No results.</div> ';
  if (!app.isSingleDoc() && !app.disabledDocs.isEmpty()) {
    html += `\
<div class="_list-note">Note: documentations must be <a href="/settings" class="_list-note-link">enabled</a> to appear in the search.</div>\
`;
  }
  return html;
};

templates.sidebarPageLink = (count) =>
  `<span role="link" class="_list-item _list-pagelink">Show more\u2026 (${count})</span>`;

templates.sidebarLabel = function (doc, options) {
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

templates.sidebarVersionedDoc = function (doc, versions, options) {
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

templates.sidebarDisabled = (options) =>
  `<h6 class="_list-title">${arrow}Disabled (${options.count}) <a href="/settings" class="_list-title-link" tabindex="-1">Customize</a></h6>`;

templates.sidebarDisabledList = (html) =>
  `<div class="_disabled-list">${html}</div>`;

templates.sidebarDisabledVersionedDoc = (doc, versions) =>
  `<a class="_list-item _list-dir _icon-${doc.icon} _list-disabled" data-slug="${doc.slug_without_version}" tabindex="-1">${arrow}${doc.name}</a><div class="_list _list-sub">${versions}</div>`;

templates.docPickerHeader =
  '<div class="_list-picker-head"><span>Documentation</span> <span>Enable</span></div>';

templates.docPickerNote = `\
<div class="_list-note">Tip: for faster and better search results, select only the docs you need.</div>
<a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank" rel="noopener">Vote for new documentation</a>\
`;
