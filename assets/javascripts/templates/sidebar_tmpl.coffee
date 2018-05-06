templates = app.templates

arrow = """<svg class="_list-arrow"><use xlink:href="#icon-dir"/></svg>"""

templates.sidebarDoc = (doc, options = {}) ->
  link  = """<a href="#{doc.fullPath()}" class="_list-item _icon-#{doc.icon} """
  link += if options.disabled then '_list-disabled' else '_list-dir'
  link += """" data-slug="#{doc.slug}" title="#{doc.fullName}" tabindex="-1">"""
  if options.disabled
    link += """<span class="_list-enable" data-enable="#{doc.slug}">#{__ 'enable'}</span>"""
  else
    link += arrow
  link += """<span class="_list-count">#{doc.release}</span>""" if doc.release
  link += """<span class="_list-text">#{doc.name}"""
  link += " #{doc.version}" if options.fullName or options.disabled and doc.version
  link + "</span></a>"

templates.sidebarType = (type) ->
  """<a href="#{type.fullPath()}" class="_list-item _list-dir" data-slug="#{type.slug}" tabindex="-1">#{arrow}<span class="_list-count">#{type.count}</span><span class="_list-text">#{$.escape type.name}</span></a>"""

templates.sidebarEntry = (entry) ->
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover" tabindex="-1">#{$.escape entry.name}</a>"""

templates.sidebarResult = (entry) ->
  addons = if entry.isIndex() and app.disabledDocs.contains(entry.doc)
    """<span class="_list-enable" data-enable="#{entry.doc.slug}">#{__ 'enable'}</span>"""
  else
    """<span class="_list-reveal" data-reset-list title="Reveal in list"></span>"""
  addons += """<span class="_list-count">#{entry.doc.short_version}</span>""" if entry.doc.version and not entry.isIndex()
  """<a href="#{entry.fullPath()}" class="_list-item _list-hover _list-result _icon-#{entry.doc.icon}" tabindex="-1">#{addons}<span class="_list-text">#{$.escape entry.name}</span></a>"""

templates.sidebarNoResults = ->
  html = """ <div class="_list-note">#{_ en: "No results.", ja: "ヒットしませんでした。"}</div> """
  html += _(
    en: """
      <div class="_list-note">Note: documentations must be <a href="/settings" class="_list-note-link">enabled</a> to appear in the search.</div>
    """
    ja: """
      <div class="_list-note">ノート: 検索で表示するには、ドキュメントを<a href="/settings" class="_list-note-link">有効</a> にすることが必要です。</div>
    """
  ) unless app.isSingleDoc() or app.disabledDocs.isEmpty()
  html

templates.sidebarPageLink = (count) ->
  """<span role="link" class="_list-item _list-pagelink">#{_ en: "Show more", ja: "もっと見る"}\u2026 (#{count})</span>"""

templates.sidebarLabel = (doc, options = {}) ->
  label = """<label class="_list-item"""
  label += " _icon-#{doc.icon}" unless doc.version
  label += """"><input type="checkbox" name="#{doc.slug}" class="_list-checkbox" """
  label += "checked" if options.checked
  label + """><span class="_list-text">#{doc.fullName}</span></label>"""

templates.sidebarVersionedDoc = (doc, versions, options = {}) ->
  html = """<div class="_list-item _list-dir _list-rdir _icon-#{doc.icon}"""
  html += " open" if options.open
  html + """" tabindex="0">#{arrow}#{doc.name}</div><div class="_list _list-sub">#{versions}</div>"""

templates.sidebarDisabled = (options) ->
  customize = _ en: "Customize", ja: "カスタマイズ"
  """<h6 class="_list-title">#{arrow}Disabled (#{options.count}) <a href="/settings" class="_list-title-link" tabindex="-1">#{customize}</a></h6>"""

templates.sidebarDisabledList = (html) ->
  """<div class="_disabled-list">#{html}</div>"""

templates.sidebarDisabledVersionedDoc = (doc, versions) ->
  """<a class="_list-item _list-dir _icon-#{doc.icon} _list-disabled" data-slug="#{doc.slug_without_version}" tabindex="-1">#{arrow}#{doc.name}</a><div class="_list _list-sub">#{versions}</div>"""

templates.docPickerHeader = -> """<div class="_list-picker-head"><span>#{__ 'documentation'}</span> <span>#{__ 'enable'}</span></div>"""

templates.docPickerNote =
  en: """
    <div class="_list-note">Tip: for faster and better search results, select only the docs you need.</div>
    <a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank" rel="noopener">Vote for new documentation</a>
  """
  ja: """
    <div class="_list-note">Tip: 検索結果を速くよくするには、必要なドキュメントだけ選択してください。</div>
    <a href="https://trello.com/b/6BmTulfx/devdocs-documentation" class="_list-link" target="_blank" rel="noopener">新しいドキュメントを投票する</a>
  """
