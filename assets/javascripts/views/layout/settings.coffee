class app.views.Settings extends app.View
  SIDEBAR_HIDDEN_LAYOUT = '_sidebar-hidden'

  @el: '._settings'

  @elements:
    sidebar: '._sidebar'
    saveBtn: 'button[type="submit"]'
    backBtn: 'button[data-back]'

  @events:
    submit: 'onSubmit'
    click: 'onClick'
    focus: 'onFocus'

  @shortcuts:
    enter: 'onEnter'

  init: ->
    @addSubview @docPicker = new app.views.DocPicker
    return

  activate: ->
    if super
      @render()
      app.el.classList.remove(SIDEBAR_HIDDEN_LAYOUT)
      app.appCache?.on 'progress', @onAppCacheProgress
    return

  deactivate: ->
    if super
      @resetClass()
      @docPicker.detach()
      app.el.classList.add(SIDEBAR_HIDDEN_LAYOUT) if app.settings.hasLayout(SIDEBAR_HIDDEN_LAYOUT)
      app.appCache?.off 'progress', @onAppCacheProgress
    return

  render: ->
    @docPicker.appendTo @sidebar
    @refreshElements()
    @addClass '_in'
    return

  save: ->
    unless @saving
      @saving = true
      docs = @docPicker.getSelectedDocs()
      app.settings.setDocs(docs)
      @saveBtn.textContent = if app.appCache then 'Downloading\u2026' else 'Saving\u2026'
      disabledDocs = new app.collections.Docs(doc for doc in app.docs.all() when docs.indexOf(doc.slug) is -1)
      disabledDocs.uninstall ->
        app.db.migrate()
        app.reload()
    return

  onEnter: =>
    @save()
    return

  onSubmit: (event) =>
    event.preventDefault()
    @save()
    return

  onClick: (event) =>
    return if event.which isnt 1
    if event.target is @backBtn
      $.stopEvent(event)
      app.router.show '/'
    return

  onFocus: (event) =>
    $.scrollTo event.target, @el, 'continuous', bottomGap: 2
    return

  onAppCacheProgress: (event) =>
    if event.lengthComputable
      percentage = Math.round event.loaded * 100 / event.total
      @saveBtn.textContent = "Downloading\u2026 (#{percentage}%)"
    return
