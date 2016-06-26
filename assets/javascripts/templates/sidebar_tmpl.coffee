templates = app.templates

templates.sidebarDoc = (doc, options = {}) ->
  link  = """<a href="#{doc.fullPath()}" class="_list-item _icon-#{doc.icon} """
  link += if options.disabled then '_list-disabled' else '_list-dir'
  link += """" data-slug="#{doc.slug}" title="#{doc.fullName}">"""
  if options.disabled
    link += """<span class="_list-enable" data-enable="#{doc.slug}">Enable</span>"""
  else
    link += """<span class="_list-arrow"></span>"""
  link += """<span class="_list-count">#{doc.release}</span>""" if doc.release
  link += """<span class="_list-text">#{doc.name}"""
  link += " #{doc.version}" if options.disabled and doc.version
  link + "</span></a>"

templates.sidebarType = (type) ->
  """<a href="#{type.fullPath()}" class="_list-item _list-dir" data-slug="#{type.slug}"><span class="_list-arrow"></span><span class="_list-count">#{type.count}</span><span class="_list-text">#{type.name}</span></a>"""

templates.sidebarEntry = (entry) ->
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover">#{$.escape entry.name}</a>"""

templates.sidebarResult = (entry) ->
  addons = if entry.isIndex() and app.disabledDocs.contains(entry.doc)
    """<span class="_list-enable" data-enable="#{entry.doc.slug}">Enable</span>"""
  else
    """<span class="_list-reveal" data-reset-list title="Reveal in list"></span>"""
  addons += """<span class="_list-count">#{entry.doc.short_version}</span>""" if entry.doc.version and not entry.isIndex()
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover _list-result _icon-#{entry.doc.icon}">#{addons}<span class="_list-text">#{$.escape entry.name}</span></a>"""

templates.sidebarNoResults = ->
  html = """ <div class="_list-note">No results.</div> """
  html += """
    <div class="_list-note">Note: documentations must be <a class="_list-note-link" data-pick-docs>enabled</a> to appear in the search.</div>
  """ unless app.isSingleDoc() or app.disabledDocs.isEmpty()
  html

templates.sidebarPageLink = (count) ->
  """<span class="_list-item _list-pagelink">Show more\u2026 (#{count})</span>"""

templates.sidebarLabel = (doc, options = {}) ->
  label = """<label class="_list-item"""
  label += " _icon-#{doc.icon}" unless doc.version
  label += """"><input type="checkbox" name="#{doc.slug}" class="_list-checkbox" """
  label += "checked" if options.checked
  label + """><span class="_list-text">#{doc.fullName}</span></label>"""

templates.sidebarVersionedDoc = (doc, versions, options = {}) ->
  html = """<div class="_list-item _list-dir _list-rdir _icon-#{doc.icon}"""
  html += " open" if options.open
  html + """"><span class="_list-arrow"></span>#{doc.name}</div><div class="_list _list-sub">#{versions}</div>"""

templates.sidebarDisabled = (options) ->
  """<h6 class="_list-title"><span class="_list-arrow"></span>Disabled (#{options.count})</h6>"""

templates.sidebarDisabledList = (html) ->
  """<div class="_disabled-list">#{html}</div>"""

templates.sidebarDisabledVersionedDoc = (doc, versions) ->
  """<a class="_list-item _list-dir _icon-#{doc.icon} _list-disabled" data-slug="#{doc.slug_without_version}"><span class="_list-arrow"></span>#{doc.name}</a><div class="_list _list-sub">#{versions}</div>"""

templates.sidebarPickerNote = """
  <div class="_list-note">Tip: for faster and better search results, select only the docs you need.</div>
  <a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank">Vote for new documentation</a>
  """

sidebarFooter = (html) -> """<div class="_sidebar-footer">#{html}</div>"""

templates.sidebarSettings = ->
  sidebarFooter """
    <button type="button" class="_sidebar-footer-link _sidebar-footer-light" title="Toggle light" data-light>Toggle light</button>
    <button type="button" class="_sidebar-footer-link _sidebar-footer-layout" title="Toggle layout" data-layout>Toggle layout</button>
    <a href="#" class="_sidebar-footer-link _sidebar-footer-edit" data-pick-docs>Select documentation</a>
  """

templates.sidebarSave = ->
  sidebarFooter """<a class="_sidebar-footer-link _sidebar-footer-save" role="button">Save</a>"""
