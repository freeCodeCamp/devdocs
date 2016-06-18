@app =
  _$: $
  _$$: $$
  _page: page
  collections: {}
  models:      {}
  templates:   {}
  views:       {}

  init: ->
    try @initErrorTracking() catch
    return unless @browserCheck()
    @showLoading()

    @el = $('._app')
    @store = new Store
    @appCache = new app.AppCache if app.AppCache.isEnabled()
    @settings = new app.Settings @store
    @db = new app.DB()

    @docs = new app.collections.Docs
    @disabledDocs = new app.collections.Docs
    @entries = new app.collections.Entries

    @router = new app.Router
    @shortcuts = new app.Shortcuts
    @document = new app.views.Document
    @mobile = new app.views.Mobile if @isMobile()

    if document.body.hasAttribute('data-doc')
      @DOC = JSON.parse(document.body.getAttribute('data-doc'))
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
          ignoreErrors: [/dpQuery/, /NPObject/, /NS_ERROR/, /^null$/]
          tags:
            mode: if @DOC then 'single' else 'full'
            iframe: (window.top isnt window).toString()
          shouldSendCallback: =>
            try
              if @isInjectionError()
                @onInjectionError()
                return false
              if @isAndroidWebview()
                return false
            true
          dataCallback: (data) ->
            try
              $.extend(data.user ||= {}, app.settings.dump())
              data.user.lastIDBTransaction = app.lastIDBTransaction if app.lastIDBTransaction
            data
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
    @migrateDocs()
    @docs.sort()
    @disabledDocs.sort()
    @docs.load @start.bind(@), @onBootError.bind(@), readCache: true, writeCache: true
    delete @DOCS
    return

  start: ->
    @entries.add doc.toEntry() for doc in @docs.all()
    @entries.add doc.toEntry() for doc in @disabledDocs.all()
    @initDoc(doc) for doc in @docs.all()
    @trigger 'ready'
    @router.start()
    @hideLoading()
    @welcomeBack() unless @doc
    @removeEvent 'ready bootError'
    try navigator.mozApps?.getSelf().onsuccess = -> app.mozApp = true catch
    return

  initDoc: (doc) ->
    @entries.add type.toEntry() for type in doc.types.all()
    @entries.add doc.entries.all()
    return

  migrateDocs: ->
    for slug in @settings.getDocs() when not @docs.findBy('slug', slug)
      needsSaving = true
      doc = @disabledDocs.findBy('slug', 'node~4_lts') if slug == 'node~4.2_lts'
      doc = @disabledDocs.findBy('slug', 'xslt_xpath') if slug == 'xpath'
      doc = @disabledDocs.findBy('slug', "angularjs~#{match[1]}") if match = /^angular~(1\.\d)$/.exec(slug)
      doc ||= @disabledDocs.findBy('slug_without_version', slug)
      if doc
        @disabledDocs.remove(doc)
        @docs.add(doc)

    @saveDocs() if needsSaving
    return

  enableDoc: (doc, _onSuccess, onError) ->
    return if @docs.contains(doc)

    onSuccess = =>
      return if @docs.contains(doc)
      @disabledDocs.remove(doc)
      @docs.add(doc)
      @docs.sort()
      @initDoc(doc)
      @saveDocs()
      _onSuccess()
      return

    doc.load onSuccess, onError, writeCache: true
    return

  saveDocs: ->
    @settings.setDocs(doc.slug for doc in @docs.all())
    @db.migrate()
    @appCache?.updateInBackground()

  welcomeBack: ->
    visitCount = @settings.get('count')
    @settings.set 'count', ++visitCount
    new app.views.Notif 'Share', autoHide: null if visitCount is 5
    new app.views.News()
    new app.views.Updates()
    @updateChecker = new app.UpdateChecker()

  reload: ->
    @docs.clearCache()
    @disabledDocs.clearCache()
    if @appCache then @appCache.reload() else window.location = '/'
    return

  reset: ->
    @store.clear()
    @settings.reset()
    @db?.reset()
    @appCache?.update()
    window.location = '/'
    return

  showTip: (tip) ->
    return if @isSingleDoc()
    tips = @settings.getTips()
    if tips.indexOf(tip) is -1
      tips.push(tip)
      @settings.setTips(tips)
      new app.views.Tip(tip)
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

  onQuotaExceeded: ->
    return if @quotaExceeded
    @quotaExceeded = true
    new app.views.Notif 'QuotaExceeded', autoHide: null
    Raven.captureMessage 'QuotaExceededError'

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
    window.$ isnt app._$ or window.$$ isnt app._$$ or window.page isnt app._page or typeof $.empty isnt 'function' or typeof page.show isnt 'function'

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
    @_isMobile ?= app.views.Mobile.detect()

  isAndroidWebview: ->
    @_isAndroidWebview ?= app.views.Mobile.detectAndroidWebview()

  isInvalidLocation: ->
    @config.env is 'production' and location.host.indexOf(app.config.production_host) isnt 0

supportsCssGradients = ->
  el = document.createElement('div')
  el.style.cssText = "background-image: -webkit-linear-gradient(top, #000, #fff); background-image: linear-gradient(to top, #000, #fff);"
  el.style.backgroundImage.indexOf('gradient') >= 0

$.extend app, Events
