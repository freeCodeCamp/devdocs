class app.views.OfflinePage extends app.View
  @className: '_static'

  @events:
    click: 'onClick'

  @elements:
    list: '_._docs'

  deactivate: ->
    if super
      @empty()
    return

  render: ->
    @html @tmpl('offlinePage')
    @refreshElements()
    app.docs.each(@renderDoc)
    return

  renderDoc: (doc) =>
    doc.getDownloadStatus (status) =>
      html = app.templates.render('offlineDocContent', doc, status)
      el = @docEl(doc)
      el.className = ''
      el.innerHTML = html
    return

  getTitle: ->
    'Offline'

  getDoc: (el) ->
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
      doc = @getDoc(event.target)
      doc[action](@onDownloadSuccess.bind(@, doc), @onDownloadError.bind(@, doc))
      @docEl(doc).classList.add("#{action}ing")
    return

  onDownloadSuccess: (doc) ->
    @renderDoc(doc)
    return

  onDownloadError: (doc) ->
    el = @docEl(doc)
    el.className = ''
    el.classList.add('error')
