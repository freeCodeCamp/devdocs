templates = app.templates

templates.sidebarDoc = (doc, options = {}) ->
  link  = """<a href="#{doc.fullPath()}" class="_list-item _icon-#{doc.slug} """
  link += if options.disabled then '_list-disabled' else '_list-dir'
  link += """" data-slug="#{doc.slug}" title="#{doc.name}">"""
  if options.disabled
    link += """<span class="_list-enable" data-enable="#{doc.slug}">Enable</span>"""
  else
    link += """<span class="_list-arrow"></span>"""
  link += """<span class="_list-count">#{doc.release}</span>""" if doc.release
  link +  "#{doc.name}</a>"

templates.sidebarType = (type) ->
  """<a href="#{type.fullPath()}" class="_list-item _list-dir" data-slug="#{type.slug}"><span class="_list-arrow"></span><span class="_list-count">#{type.count}</span>#{type.name}</a>"""

templates.sidebarEntry = (entry) ->
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover">#{$.escape entry.name}</a>"""

templates.sidebarResult = (entry) ->
  addon = if entry.isIndex() and app.disabledDocs.contains(entry.doc)
    """<span class="_list-enable" data-enable="#{entry.doc.slug}">Enable</span>"""
  else
    """<span class="_list-reveal" data-reset-list title="Reveal in list"></span>"""
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover _list-result _icon-#{entry.doc.slug}">#{addon}#{$.escape entry.name}</a>"""

templates.sidebarNoResults = ->
  html = """ <div class="_list-note">No results.</div> """
  html += """
    <div class="_list-note">Note: documentations must be <a class="_list-note-link" data-pick-docs>enabled</a> to appear in the search.</div>
  """ unless app.isSingleDoc() or app.disabledDocs.isEmpty()
  html

templates.sidebarPageLink = (count) ->
  """<span class="_list-item _list-pagelink">Show more\u2026 (#{count})</span>"""

templates.sidebarLabel = (doc, options = {}) ->
  label = """<label class="_list-item _list-label _icon-#{doc.slug}"""
  label += ' _list-label-off' unless options.checked
  label += """"><input type="checkbox" name="#{doc.slug}" class="_list-checkbox" """
  label += 'checked' if options.checked
  label +  ">#{doc.name}</label>"

templates.sidebarDisabledList = (options) ->
  """<div class="_disabled-list">#{templates.render 'sidebarDoc', options.docs, disabled: true}</div>"""

templates.sidebarDisabled = (options) ->
  """<h6 class="_list-title"><span class="_list-arrow"></span>Disabled (#{options.count})</h6>"""

templates.sidebarPickerNote = """
  <div class="_list-note">Tip: for faster and better search results, select only the docs you need.</div>
  <a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank">Vote for new documentation</a>
  """

sidebarFooter = (html) -> """<div class="_sidebar-footer">#{html}</div>"""

templates.sidebarSettings = ->
  sidebarFooter """
    <a class="_sidebar-footer-link _sidebar-footer-light" title="Toggle light" data-light></a>
    <a class="_sidebar-footer-link _sidebar-footer-layout" title="Toggle layout" data-layout></a>
    <a class="_sidebar-footer-link _sidebar-footer-edit" data-pick-docs>Select documentation</a>
  """

templates.sidebarSave = ->
  sidebarFooter """<a class="_sidebar-footer-link _sidebar-footer-save">Save</a>"""
