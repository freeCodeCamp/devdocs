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
      app.appCache?.on 'progress', @onAppCacheProgress
    return

  deactivate: ->
    if super
      @empty()
      app.appCache?.off 'progress', @onAppCacheProgress
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
      app.settings.setDocs @getSelectedDocs()
      @saveLink.textContent = if app.appCache then 'Downloading...' else 'Saving...'
      app.reload()
    return

  getSelectedDocs: ->
    for input in @findAllByTag 'input' when input?.checked
      input.name

  onClick: (event) =>
    if event.target is @saveLink
      $.stopEvent(event)
      @save()
    return

  onEnter: =>
    @save()
    return

  onAppCacheProgress: (event) =>
    if event.lengthComputable
      percentage = Math.round event.loaded * 100 / event.total
      @saveLink.textContent = "Downloading... (#{percentage}%)"
    return
