class app.UpdateChecker
  constructor: ->
    @lastCheck = Date.now()

    $.on window, 'focus', @onFocus
    app.serviceWorker?.on 'updateready', @onUpdateReady

    setTimeout @checkDocs, 0

  check: ->
    if app.serviceWorker
      app.serviceWorker.update()
    else
      ajax
        url: $('script[src*="application"]').getAttribute('src')
        dataType: 'application/javascript'
        error: (_, xhr) => @onUpdateReady() if xhr.status is 404
    return

  onUpdateReady: ->
    new app.views.Notif 'UpdateReady', autoHide: null
    return

  checkDocs: =>
    unless app.settings.get('manualUpdate')
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
