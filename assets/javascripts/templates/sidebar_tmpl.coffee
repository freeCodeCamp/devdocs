templates = app.templates

templates.sidebarDoc = (doc, options = {}) ->
  link  = """<a href="#{doc.fullPath()}" class="_list-item _icon-#{doc.slug} """
  link += if options.disabled then '_list-disabled' else '_list-dir'
  link += """" data-slug="#{doc.slug}">"""
  link += """<span class="_list-arrow"></span>""" unless options.disabled
  link += """<span class="_list-count">#{doc.version}</span>""" if doc.version
  link +  "#{doc.name}</a>"

templates.sidebarType = (type) ->
  """<a href="#{type.fullPath()}" class="_list-item _list-dir" data-slug="#{type.slug}"><span class="_list-arrow"></span><span class="_list-count">#{type.count}</span>#{type.name}</a>"""

templates.sidebarEntry = (entry) ->
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover">#{$.escape entry.name}</a>"""

templates.sidebarResult = (entry) ->
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover _list-result _icon-#{entry.doc.slug}"><span class="_list-reveal" data-reset-list title="Reveal in list"></span>#{$.escape entry.name}</a>"""

templates.sidebarNoResults = ->
  info = if app.isSingleDoc() or !app.disabledDocs.isEmpty() then '' else """
    <span class="_list-noresults-note">Note: documentations must be <a class="_list-noresults-link" data-pick-docs>enabled</a> to appear in the search.</span>
  """
  """ <div class="_list-noresults">No results. #{info}</div> """

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

templates.sidebarVote = '<a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank">Vote for new documentation</a>'

sidebarFooter = (html) -> """<div class="_sidebar-footer">#{html}</div>"""

templates.sidebarSettings = ->
  sidebarFooter """<a class="_sidebar-footer-link _sidebar-footer-edit" data-pick-docs>Select documentation</a>"""

templates.sidebarSave = ->
  sidebarFooter """<a class="_sidebar-footer-link _sidebar-footer-save">Save</a>"""
