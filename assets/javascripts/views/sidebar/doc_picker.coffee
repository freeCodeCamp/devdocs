class app.views.DocPicker extends app.View
  @className: '_list'

  @elements:
    saveLink: '._sidebar-footer-save'

  @events:
    click: 'onClick'

  @shortcuts:
    enter: 'onEnter'

  activate: ->
    if super
      @render()
      @findByTag('input').focus()
      app.appCache?.on 'progress', @onAppCacheProgress
      $.on @el, 'focus', @onFocus, true
    return

  deactivate: ->
    if super
      @empty()
      app.appCache?.off 'progress', @onAppCacheProgress
      $.off @el, 'focus', @onFocus, true
    return

  render: ->
    @html @tmpl('sidebarLabel', app.docs.all(), checked: true) +
          @tmpl('sidebarLabel', app.disabledDocs.all()) +
          @tmpl('sidebarVote') +
          @tmpl('sidebarSave')

    @refreshElements()

    @delay -> # trigger animation
      @el.offsetWidth
      @addClass '_in'
    return

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
      disabledDocs.undownload -> app.reload()
    return

  getSelectedDocs: ->
    for input in @findAllByTag 'input' when input?.checked
      input.name

  onClick: (event) =>
    if event.target is @saveLink
      $.stopEvent(event)
      @save()
    return

  onFocus: (event) ->
    $.scrollTo event.target.parentNode, null, 'continuous', bottomGap: 2

  onEnter: =>
    @save()
    return

  onAppCacheProgress: (event) =>
    if event.lengthComputable
      percentage = Math.round event.loaded * 100 / event.total
      @saveLink.textContent = "Downloading\u2026 (#{percentage}%)"
    return
