class app.AppCache
  $.extend @prototype, Events

  @isEnabled: ->
    try
      applicationCache and applicationCache.status isnt applicationCache.UNCACHED
    catch

  constructor: ->
    @cache = applicationCache
    @onUpdateReady() if @cache.status is @cache.UPDATEREADY

    $.on @cache, 'progress', @onProgress
    $.on @cache, 'updateready', @onUpdateReady

    @lastCheck = Date.now()
    $.on window, 'focus', @checkForUpdate

  update: ->
    try @cache.update() catch
    return

  reload: ->
    @reloading = true
    $.on @cache, 'updateready noupdate error', -> window.location = '/'
    @update()
    return

  checkForUpdate: =>
    if Date.now() - @lastCheck > 86400e3
      @lastCheck = Date.now()
      @update()
    return

  onProgress: (event) =>
    @trigger 'progress', event
    return

  onUpdateReady: =>
    new app.views.Notif 'UpdateReady' unless @reloading
    @trigger 'updateready'
    return
