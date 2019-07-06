class app.views.Settings extends app.View
  SIDEBAR_HIDDEN_LAYOUT = '_sidebar-hidden'

  @el: '._settings'

  @elements:
    sidebar: '._sidebar'
    saveBtn: 'button[type="submit"]'
    backBtn: 'button[data-back]'

  @events:
    import: 'onImport'
    change: 'onChange'
    submit: 'onSubmit'
    click: 'onClick'

  @shortcuts:
    enter: 'onEnter'

  init: ->
    @addSubview @docPicker = new app.views.DocPicker
    return

  activate: ->
    if super
      @render()
      document.body.classList.remove(SIDEBAR_HIDDEN_LAYOUT)
    return

  deactivate: ->
    if super
      @resetClass()
      @docPicker.detach()
      document.body.classList.add(SIDEBAR_HIDDEN_LAYOUT) if app.settings.hasLayout(SIDEBAR_HIDDEN_LAYOUT)
    return

  render: ->
    @docPicker.appendTo @sidebar
    @refreshElements()
    @addClass '_in'
    return

  save: (options = {}) ->
    unless @saving
      @saving = true

      if options.import
        docs = app.settings.getDocs()
      else
        docs = @docPicker.getSelectedDocs()
        app.settings.setDocs(docs)

      @saveBtn.textContent = 'Saving\u2026'
      disabledDocs = new app.collections.Docs(doc for doc in app.docs.all() when docs.indexOf(doc.slug) is -1)
      disabledDocs.uninstall ->
        app.db.migrate()
        app.reload()
    return

  onChange: =>
    @addClass('_dirty')
    return

  onEnter: =>
    @save()
    return

  onSubmit: (event) =>
    event.preventDefault()
    @save()
    return

  onImport: =>
    @addClass('_dirty')
    @save(import: true)
    return

  onClick: (event) =>
    return if event.which isnt 1
    if event.target is @backBtn
      $.stopEvent(event)
      app.router.show '/'
    return
