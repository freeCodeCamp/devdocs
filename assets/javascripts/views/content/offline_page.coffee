class app.views.OfflinePage extends app.View
  @className: '_static'

  @events:
    click: 'onClick'

  deactivate: ->
    if super
      @empty()
    return

  render: ->
    app.docs.getInstallStatuses (statuses) =>
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
    target = event.target
    if action = target.getAttribute('data-action')
      $.stopEvent(event)
      doc = @docByEl(target)
      doc[action](@onInstallSuccess.bind(@, doc), @onInstallError.bind(@, doc))
      target.parentNode.innerHTML = "#{target.textContent.replace(/e$/, '')}ing…"
    return

  onInstallSuccess: (doc) ->
    doc.getInstallStatus (status) =>
      @docEl(doc).outerHTML = @renderDoc(doc, status)
      $.highlight @docEl(doc), className: '_highlight'
    return

  onInstallError: (doc) ->
    el = @docEl(doc)
    el.lastElementChild.textContent = 'Error'
    return
