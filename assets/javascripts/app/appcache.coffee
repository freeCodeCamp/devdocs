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

  update: ->
    try @cache.update() catch
    return

  reload: ->
    @reloading = true
    $.on @cache, 'updateready noupdate error', -> window.location = '/'
    @update()
    return

  onProgress: (event) =>
    @trigger 'progress', event
    return

  onUpdateReady: =>
    @trigger 'updateready' unless @reloading
    return
