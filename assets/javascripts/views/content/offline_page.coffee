class app.views.OfflinePage extends app.View
  @className: '_static'

  @events:
    click: 'onClick'

  deactivate: ->
    if super
      @empty()
    return

  render: ->
    app.docs.getDownloadStatuses (statuses) =>
      if statuses is false
        @html @tmpl('offlineError')
      else
        html = ''
        html += @renderDoc(doc, statuses[doc.slug]) for doc in app.docs.all()
        @html @tmpl('offlinePage', html)
      return
    return

  renderDoc: (doc, status) ->
    app.templates.render('offlineDoc', doc, status)

  getTitle: ->
    'Offline'

  docByEl: (el) ->
    el = el.parentNode until slug = el.getAttribute('data-slug')
    app.docs.findBy('slug', slug)

  docEl: (doc) ->
    @find("[data-slug='#{doc.slug}']")

  onRoute: ->
    @render()
    return

  onClick: (event) =>
    if event.target.hasAttribute('data-dl')
      action = 'download'
    else if event.target.hasAttribute('data-del')
      action = 'undownload'

    if action
      $.stopEvent(event)
      doc = @docByEl(event.target)
      doc[action](@onDownloadSuccess.bind(@, doc), @onDownloadError.bind(@, doc))
      @docEl(doc).classList.add("#{action}ing")
    return

  onDownloadSuccess: (doc) ->
    doc.getDownloadStatus (status) =>
      @docEl(doc).outerHTML = @renderDoc(doc, status)
    return

  onDownloadError: (doc) ->
    el = @docEl(doc)
    el.className = ''
    el.classList.add('error')
    return
