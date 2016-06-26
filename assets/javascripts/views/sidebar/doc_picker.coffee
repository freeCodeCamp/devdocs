class app.views.DocPicker extends app.View
  @className: '_list _list-picker'
  @attributes:
    role: 'form'

  @elements:
    saveLink: '._sidebar-footer-save'

  @events:
    click: 'onClick'

  @shortcuts:
    enter: 'onEnter'

  init: ->
    @addSubview @listFold = new app.views.ListFold(@el)
    return

  activate: ->
    if super
      @render()
      @findByTag('input')?.focus()
      app.appCache?.on 'progress', @onAppCacheProgress
      $.on @el, 'focus', @onDOMFocus, true
    return

  deactivate: ->
    if super
      @empty()
      app.appCache?.off 'progress', @onAppCacheProgress
      $.off @el, 'focus', @onDOMFocus, true
    return

  render: ->
    html = ''
    docs = app.docs.all().concat(app.disabledDocs.all()...)

    while doc = docs.shift()
      if doc.version?
        [docs, versions] = @extractVersions(docs, doc)
        html += @tmpl('sidebarVersionedDoc', doc, @renderVersions(versions), open: app.docs.contains(doc))
      else
        html += @tmpl('sidebarLabel', doc, checked: app.docs.contains(doc))

    @html html + @tmpl('sidebarPickerNote') + @tmpl('sidebarSave')
    @refreshElements()

    @delay -> # trigger animation
      @el.offsetWidth
      @addClass '_in'
    return

  renderVersions: (docs) ->
    html = ''
    html += @tmpl('sidebarLabel', doc, checked: app.docs.contains(doc)) for doc in docs
    html

  extractVersions: (originalDocs, version) ->
    docs = []
    versions = [version]
    for doc in originalDocs
      (if doc.name is version.name then versions else docs).push(doc)
    [docs, versions]

  empty: ->
    @resetClass()
    super
    return

  save: ->
    unless @saving
      @saving = true
      docs = @getSelectedDocs()
      app.settings.setDocs(docs)
      @saveLink.textContent = if app.appCache then 'Downloading\u2026' else 'Saving\u2026'
      disabledDocs = new app.collections.Docs(doc for doc in app.docs.all() when docs.indexOf(doc.slug) is -1)
      disabledDocs.uninstall ->
        app.db.migrate()
        app.reload()
    return

  getSelectedDocs: ->
    for input in @findAllByTag 'input' when input?.checked
      input.name

  onClick: (event) =>
    if @focusTimeout
      clearTimeout @focusTimeout
      @focusTimeout = null
    return if event.which isnt 1
    if event.target is @saveLink
      $.stopEvent(event)
      @save()
    return

  onDOMFocus: (event) =>
    target = event.target
    if target.tagName is 'INPUT'
      $.scrollTo target.parentNode, null, 'continuous', bottomGap: 2
    else if target.classList.contains(app.views.ListFold.targetClass)
      target.blur()
      @focusTimeout = setTimeout =>
        @listFold.open(target) unless target.classList.contains(app.views.ListFold.activeClass)
        $('input', target.nextElementSibling).focus()
        @focusTimeout = null
      , 10
    return

  onEnter: =>
    @save()
    return

  onAppCacheProgress: (event) =>
    if event.lengthComputable
      percentage = Math.round event.loaded * 100 / event.total
      @saveLink.textContent = "Downloading\u2026 (#{percentage}%)"
    return
