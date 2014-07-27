class app.views.Content extends app.View
  @el: '._content'
  @loadingClass: '_content-loading'

  @events:
    click: 'onClick'

  @shortcuts:
    altUp:    'scrollStepUp'
    altDown:  'scrollStepDown'
    pageUp:   'scrollPageUp'
    pageDown: 'scrollPageDown'
    home:     'scrollToTop'
    end:      'scrollToBottom'
    altF:     'onAltF'

  @routes:
    before: 'beforeRoute'
    after:  'afterRoute'

  init: ->
    @scrollEl = if app.isMobile() then document.body else @el
    @scrollMap = {}
    @scrollStack = []

    @rootPage   = new app.views.RootPage
    @staticPage = new app.views.StaticPage
    @typePage   = new app.views.TypePage
    @entryPage  = new app.views.EntryPage

    @entryPage
      .on 'loading', @onEntryLoading
      .on 'loaded', @onEntryLoaded

    app
      .on 'ready', @onReady
      .on 'bootError', @onBootError

    return

  show: (view) ->
    unless view is @view
      @view?.deactivate()
      @html @view = view
      @view.activate()
    return

  showLoading: ->
    @addClass @constructor.loadingClass
    return

  hideLoading: ->
    @removeClass @constructor.loadingClass
    return

  scrollTo: (value) ->
    @scrollEl.scrollTop = value or 0
    return

  scrollBy: (n) ->
    @scrollEl.scrollTop += n
    return

  scrollToTop: =>
    @scrollTo 0
    return

  scrollToBottom: =>
    @scrollTo @scrollEl.scrollHeight
    return

  scrollStepUp: =>
    @scrollBy -50
    return

  scrollStepDown: =>
    @scrollBy 50
    return

  scrollPageUp: =>
    @scrollBy 80 - @scrollEl.clientHeight
    return

  scrollPageDown: =>
    @scrollBy @scrollEl.clientHeight - 80
    return

  scrollToTarget: ->
    if @routeCtx.hash and el = @findTargetByHash @routeCtx.hash
      $.scrollToWithImageLock el, @scrollEl, 'top',
        margin: 20 + if @scrollEl is @el then 0 else $.offset(@el).top
      $.highlight el, className: '_highlight'
    else
      @scrollTo @scrollMap[@routeCtx.state.id]
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
    @delay @scrollToTarget
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
      @findByTag('a')?.focus()
      $.stopEvent(event)

  findTargetByHash: (hash) ->
    try $.id decodeURIComponent(hash) catch

  isExternalUrl: (url) ->
    url?[0..5] in ['http:/', 'https:']
