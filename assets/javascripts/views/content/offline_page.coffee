class app.views.OfflinePage extends app.View
  @className: '_static'

  @events:
    click: 'onClick'
    change: 'onChange'

  deactivate: ->
    if super
      @empty()
    return

  render: ->
    if app.cookieBlocked
      @html @tmpl('offlineError', 'cookie_blocked')
      return

    app.docs.getInstallStatuses (statuses) =>
      return unless @activated
      if statuses is false
        @html @tmpl('offlineError', app.db.reason)
      else
        html = ''
        html += @renderDoc(doc, statuses[doc.slug]) for doc in app.docs.all()
        @html @tmpl('offlinePage', html)
        @refreshLinks()
      return
    return

  renderDoc: (doc, status) ->
    app.templates.render('offlineDoc', doc, status)

  getTitle: ->
    'Offline'

  refreshLinks: ->
    for action in ['install', 'update', 'uninstall']
      @find("a[data-action-all='#{action}']").classList[if @find("a[data-action='#{action}']") then 'add' else 'remove']('_show')
    return

  docByEl: (el) ->
    el = el.parentNode until slug = el.getAttribute('data-slug')
    app.docs.findBy('slug', slug)

  docEl: (doc) ->
    @find("[data-slug='#{doc.slug}']")

  onRoute: (route) ->
    if app.isSingleDoc()
      window.location = "/#/#{route.path}"
    else
      @render()
    return

  onClick: (event) =>
    return unless link = $.closestLink(event.target)
    if action = link.getAttribute('data-action')
      $.stopEvent(event)
      doc = @docByEl(link)
      action = 'install' if action is 'update'
      doc[action](@onInstallSuccess.bind(@, doc), @onInstallError.bind(@, doc), @onInstallProgress.bind(@, doc))
      link.parentNode.innerHTML = "#{link.textContent.replace(/e$/, '')}ing…"
    else if action = link.getAttribute('data-action-all')
      $.stopEvent(event)
      app.db.migrate()
      el.click() for el in @findAll("a[data-action='#{action}']")
    return

  onInstallSuccess: (doc) ->
    return unless @activated
    doc.getInstallStatus (status) =>
      return unless @activated
      if el = @docEl(doc)
        el.outerHTML = @renderDoc(doc, status)
        $.highlight el, className: '_highlight'
        @refreshLinks()
      return
    return

  onInstallError: (doc) ->
    return unless @activated
    if el = @docEl(doc)
      el.lastElementChild.textContent = 'Error'
    return

  onInstallProgress: (doc, event) ->
    return unless @activated and event.lengthComputable
    if el = @docEl(doc)
      percentage = Math.round event.loaded * 100 / event.total
      el.lastElementChild.textContent = el.lastElementChild.textContent.replace(/(\s.+)?$/, " (#{percentage}%)")
    return

  onChange: (event) ->
    if event.target.name is 'autoUpdate'
      app.settings.set 'manualUpdate', !event.target.checked
    return
