class app.UpdateChecker
  constructor: ->
    @lastCheck = Date.now()

    $.on window, 'focus', @checkForUpdate
    app.appCache.on 'updateready', @onUpdateReady if app.appCache

    @checkDocs()

  check: ->
    if app.appCache
      app.appCache.update()
    else
      ajax
        url: $('script[src*="application"]').getAttribute('src')
        dataType: 'application/javascript'
        error: (_, xhr) => @onUpdateReady() if xhr.status is 404
    return

  onUpdateReady: ->
    new app.views.Notif 'UpdateReady', autoHide: null
    return

  checkDocs: ->
    if app.settings.get('autoUpdate')
      app.docs.updateInBackground()
    else
      app.docs.checkForUpdates (i) => @onDocsUpdateReady() if i > 0
    return

  onDocsUpdateReady: ->
    new app.views.Notif 'UpdateDocs', autoHide: null
    return

  onFocus: =>
    if Date.now() - @lastCheck > 21600e3
      @lastCheck = Date.now()
      @check()
    return
