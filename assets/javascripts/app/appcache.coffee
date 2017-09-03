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
    @notifyProgress = true
    try @cache.update() catch
    return

  updateInBackground: ->
    @notifyUpdate = false
    @notifyProgress = false
    try @cache.update() catch
    return

  reload: ->
    $.on @cache, 'updateready noupdate error', -> window.location = '/'
    @notifyUpdate = false
    @notifyProgress = true
    try @cache.update() catch
    return

  onProgress: (event) =>
    @trigger 'progress', event if @notifyProgress
    return

  onUpdateReady: =>
    @trigger 'updateready' if @notifyUpdate
    return
