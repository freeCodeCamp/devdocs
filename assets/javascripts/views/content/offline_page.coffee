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
        @html @tmpl('offlineError', app.db.reason, app.db.error)
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
      @find("[data-action-all='#{action}']").classList[if @find("[data-action='#{action}']") then 'add' else 'remove']('_show')
    return

  docByEl: (el) ->
    el = el.parentNode until slug = el.getAttribute('data-slug')
    app.docs.findBy('slug', slug)

  docEl: (doc) ->
    @find("[data-slug='#{doc.slug}']")

  onRoute: (context) ->
    @render()
    return

  onClick: (event) =>
    el = $.eventTarget(event)
    if action = el.getAttribute('data-action')
      doc = @docByEl(el)
      action = 'install' if action is 'update'
      doc[action](@onInstallSuccess.bind(@, doc), @onInstallError.bind(@, doc), @onInstallProgress.bind(@, doc))
      el.parentNode.innerHTML = "#{el.textContent.replace(/e$/, '')}ing…"
    else if action = el.getAttribute('data-action-all')
      app.db.migrate()
      $.click(el) for el in @findAll("[data-action='#{action}']")
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
