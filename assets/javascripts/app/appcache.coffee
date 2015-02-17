class app.AppCache
  $.extend @prototype, Events

  @isEnabled: ->
    try
      applicationCache and applicationCache.status isnt applicationCache.UNCACHED
    catch

  constructor: ->
    @cache = applicationCache
    @notifyUpdate = true
    @onUpdateReady() if @cache.status is @cache.UPDATEREADY

    $.on @cache, 'progress', @onProgress
    $.on @cache, 'updateready', @onUpdateReady

  update: ->
    @notifyUpdate = true
    try @cache.update() catch
    return

  updateInBackground: ->
    @notifyUpdate = false
    try @cache.update() catch
    return

  reload: ->
    $.on @cache, 'updateready noupdate error', -> window.location = '/'
    @updateInBackground()
    return

  onProgress: (event) =>
    @trigger 'progress', event
    return

  onUpdateReady: =>
    @trigger 'updateready' if @notifyUpdate
    return
