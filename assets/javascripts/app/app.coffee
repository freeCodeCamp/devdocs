@app =
  $: $
  collections: {}
  models:      {}
  templates:   {}
  views:       {}

  init: ->
    try @initErrorTracking() catch
    return unless @browserCheck()
    @showLoading()

    @store = new Store
    @appCache = new app.AppCache if app.AppCache.isEnabled()
    @settings = new app.Settings

    @docs = new app.collections.Docs
    @disabledDocs = new app.collections.Docs
    @entries = new app.collections.Entries

    @router = new app.Router
    @shortcuts = new app.Shortcuts
    @document = new app.views.Document
    @mobile = new app.views.Mobile if @isMobile()

    if navigator.userAgent.match /iPad;.*CPU.*OS 7_\d/i
      document.documentElement.style.height = "#{window.innerHeight}px"

    if @DOC
      @bootOne()
    else if @DOCS
      @bootAll()
    else
      @onBootError()
    return

  browserCheck: ->
    return true if @isSupportedBrowser()
    document.body.className = ''
    document.body.innerHTML = app.templates.unsupportedBrowser
    false

  initErrorTracking: ->
    # Show a warning message and don't track errors when the app is loaded
    # from a domain other than our own, because things are likely to break.
    # (e.g. cross-domain requests)
    if @isInvalidLocation()
      new app.views.Notif 'InvalidLocation'
    else
      if @config.sentry_dsn
        Raven.config @config.sentry_dsn,
          whitelistUrls: [/devdocs/]
          includePaths: [/devdocs/]
          ignoreErrors: [/dpQuery/]
        .install()
      @previousErrorHandler = onerror
      window.onerror = @onWindowError.bind(@)
    return

  bootOne: ->
    @doc = new app.models.Doc @DOC
    @docs.reset [@doc]
    @doc.load @start.bind(@), @onBootError.bind(@), readCache: true
    new app.views.Notice 'singleDoc', @doc
    delete @DOC
    return

  bootAll: ->
    docs = @settings.getDocs()
    for doc in @DOCS
      (if docs.indexOf(doc.slug) >= 0 then @docs else @disabledDocs).add(doc)
    @docs.sort()
    @disabledDocs.sort()
    @docs.load @start.bind(@), @onBootError.bind(@), readCache: true, writeCache: true
    delete @DOCS
    return

  start: ->
    for doc in @docs.all()
      @entries.add doc.toEntry()
      @entries.add type.toEntry() for type in doc.types.all()
      @entries.add doc.entries.all()
    @trigger 'ready'
    @router.start()
    @hideLoading()
    new app.views.News() unless @doc
    @removeEvent 'ready bootError'
    return

  reload: ->
    @docs.clearCache()
    @disabledDocs.clearCache()
    if @appCache then @appCache.reload() else window.location = '/'
    return

  reset: ->
    @store.clear()
    @settings.reset()
    @appCache?.update()
    window.location = '/'
    return

  showLoading: ->
    document.body.classList.remove '_noscript'
    document.body.classList.add '_loading'
    return

  hideLoading: ->
    document.body.classList.remove '_booting'
    document.body.classList.remove '_loading'
    return

  indexHost: ->
    # Can't load the index files from the host/CDN when applicationCache is
    # enabled because it doesn't support caching URLs that use CORS.
    @config[if @appCache and @settings.hasDocs() then 'index_path' else 'docs_host']

  onBootError: (args...) ->
    @trigger 'bootError'
    @hideLoading()
    return

  onWindowError: (args...) ->
    if @isInjectionError args...
      @onInjectionError()
    else if @isAppError args...
      @previousErrorHandler? args...
      @hideLoading()
      @errorNotif or= new app.views.Notif 'Error'
      @errorNotif.show()
    return

  onInjectionError: ->
    unless @injectionError
      @injectionError = true
      alert """
        JavaScript code has been injected in the page which prevents DevDocs from running correctly.
        Please check your browser extensions/addons. """
      Raven.captureMessage 'injection error'
    return

  isInjectionError: ->
    # Some browser extensions expect the entire web to use jQuery.
    # I gave up trying to fight back.
    window.$ isnt app.$

  isAppError: (error, file) ->
    # Ignore errors from external scripts.
    file and file.indexOf('devdocs') isnt -1 and file.indexOf('.js') is file.length - 3

  isSupportedBrowser: ->
    try
      features =
        bind:               !!Function::bind
        pushState:          !!history.pushState
        matchMedia:         !!window.matchMedia
        classList:          !!document.body.classList
        insertAdjacentHTML: !!document.body.insertAdjacentHTML
        defaultPrevented:     document.createEvent('CustomEvent').defaultPrevented is false
        cssGradients:         supportsCssGradients()

      for key, value of features when not value
        Raven.captureMessage "unsupported/#{key}"
        return false

      true
    catch error
      Raven.captureMessage 'unsupported/exception', extra: { error: error }
      false

  isSingleDoc: ->
    !!(@DOC or @doc)

  isMobile: ->
    # Need to sniff the user agent because some Android and Windows Phone devices don't take
    # resolution (dpi) into account when reporting device width/height.
    @_isMobile ?= (matchMedia('(max-device-width: 767px), (max-device-height: 767px)').matches) or
                  (navigator.userAgent.indexOf('Android') isnt -1 and navigator.userAgent.indexOf('Mobile') isnt -1) or
                  (navigator.userAgent.indexOf('IEMobile') isnt -1)

  isInvalidLocation: ->
    @config.env is 'production' and location.host.indexOf(app.config.production_host) isnt 0

supportsCssGradients = ->
  el = document.createElement('div')
  el.style.cssText = "background-image: -webkit-linear-gradient(top, #000, #fff); background-image: linear-gradient(to top, #000, #fff);"
  el.style.backgroundImage.indexOf('gradient') >= 0

$.extend app, Events
