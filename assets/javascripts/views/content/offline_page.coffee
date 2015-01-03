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
      return unless @activated
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
    link = event.target

    if link.hasAttribute('data-dl')
      action = 'download'
    else if link.hasAttribute('data-del')
      action = 'undownload'

    if action
      $.stopEvent(event)
      doc = @docByEl(link)
      doc[action](@onDownloadSuccess.bind(@, doc), @onDownloadError.bind(@, doc))
      link.parentNode.innerHTML = "#{link.textContent.replace(/e$/, '')}ing…"
    return

  onDownloadSuccess: (doc) ->
    doc.getDownloadStatus (status) =>
      @docEl(doc).outerHTML = @renderDoc(doc, status)
      $.highlight @docEl(doc), className: '_highlight'
    return

  onDownloadError: (doc) ->
    el = @docEl(doc)
    el.lastElementChild.textContent = 'Error'
    return
