class app.views.Content extends app.View
  @el: '._content'
  @loadingClass: '_content-loading'

  @events:
    click: 'onClick'

  @shortcuts:
    altUp:      'scrollStepUp'
    altDown:    'scrollStepDown'
    pageUp:     'scrollPageUp'
    pageDown:   'scrollPageDown'
    pageTop:    'scrollToTop'
    pageBottom: 'scrollToBottom'
    altF:       'onAltF'

  @routes:
    before: 'beforeRoute'
    after:  'afterRoute'

  init: ->
    @scrollEl = if app.isMobile() then document.body else @el
    @scrollMap = {}
    @scrollStack = []

    @rootPage     = new app.views.RootPage
    @staticPage   = new app.views.StaticPage
    @settingsPage = new app.views.SettingsPage
    @offlinePage  = new app.views.OfflinePage
    @typePage     = new app.views.TypePage
    @entryPage    = new app.views.EntryPage

    @entryPage
      .on 'loading', @onEntryLoading
      .on 'loaded', @onEntryLoaded

    app
      .on 'ready', @onReady
      .on 'bootError', @onBootError

    return

  show: (view) ->
    @hideLoading()
    unless view is @view
      @view?.deactivate()
      @html @view = view
      @view.activate()
    return

  showLoading: ->
    @addClass @constructor.loadingClass
    return

  isLoading: ->
    @el.classList.contains @constructor.loadingClass

  hideLoading: ->
    @removeClass @constructor.loadingClass
    return

  scrollTo: (value) ->
    @scrollEl.scrollTop = value or 0
    return

  smoothScrollTo: (value) ->
    $.smoothScroll @scrollEl, value or 0
    return

  scrollBy: (n) ->
    @smoothScrollTo @scrollEl.scrollTop + n
    return

  scrollToTop: =>
    @smoothScrollTo 0
    return

  scrollToBottom: =>
    @smoothScrollTo @scrollEl.scrollHeight
    return

  scrollStepUp: =>
    @scrollBy -80
    return

  scrollStepDown: =>
    @scrollBy 80
    return

  scrollPageUp: =>
    @scrollBy 40 - @scrollEl.clientHeight
    return

  scrollPageDown: =>
    @scrollBy @scrollEl.clientHeight - 40
    return

  scrollToTarget: ->
    return if @isLoading()
    if @routeCtx.hash and el = @findTargetByHash @routeCtx.hash
      $.scrollToWithImageLock el, @scrollEl, 'top',
        margin: 20 + if @scrollEl is @el then 0 else $.offset(@el).top
      $.highlight el, className: '_highlight'
    else
      @scrollTo @scrollMap[@routeCtx.state.id]
    clearTimeout @scrollTimeout
    return

  onReady: =>
    @hideLoading()
    return

  onBootError: =>
    @hideLoading()
    @html @tmpl('bootError')
    return

  onEntryLoading: =>
    @showLoading()
    return

  onEntryLoaded: =>
    @hideLoading()
    @scrollToTarget()
    return

  beforeRoute: (context) =>
    @cacheScrollPosition()
    @routeCtx = context
    @scrollTimeout = @delay @scrollToTarget
    return

  cacheScrollPosition: ->
    return if not @routeCtx or @routeCtx.hash

    unless @scrollMap[@routeCtx.state.id]?
      @scrollStack.push @routeCtx.state.id
      while @scrollStack.length > app.config.history_cache_size
        delete @scrollMap[@scrollStack.shift()]

    @scrollMap[@routeCtx.state.id] = @scrollEl.scrollTop
    return

  afterRoute: (route, context) =>
    switch route
      when 'root'
        @show @rootPage
      when 'entry'
        @show @entryPage
      when 'type'
        @show @typePage
      when 'settings'
        @show @settingsPage
      when 'offline'
        @show @offlinePage
      else
        @show @staticPage

    @view.onRoute(context)
    app.document.setTitle @view.getTitle?()
    return

  onClick: (event) =>
    link = $.closestLink event.target, @el
    if link and @isExternalUrl link.getAttribute('href')
      $.stopEvent(event)
      $.popup(link)
    return

  onAltF: (event) =>
    unless document.activeElement and $.hasChild @el, document.activeElement
      @find('a:not(:empty)')?.focus()
      $.stopEvent(event)

  findTargetByHash: (hash) ->
    el = try $.id decodeURIComponent(hash) catch
    el or= try $.id(hash) catch
    el

  isExternalUrl: (url) ->
    url?[0..5] in ['http:/', 'https:']
