class app.ServiceWorker
  $.extend @prototype, Events

  @isEnabled: ->
    !!navigator.serviceWorker

  constructor: ->
    @registration = null
    @notifyUpdate = true

    navigator.serviceWorker.register(app.config.service_worker_path, {scope: '/'})
      .then((registration) => @updateRegistration(registration))
      .catch((error) -> console.error 'Could not register service worker:', error)

  update: ->
    return unless @registration
    @notifyUpdate = true
    return @registration.update().catch(->)

  updateInBackground: ->
    return unless @registration
    @notifyUpdate = false
    return @registration.update().catch(->)

  reload: ->
    return @updateInBackground().then(() -> app.reboot())

  updateRegistration: (registration) ->
    @registration = registration
    $.on @registration, 'updatefound', @onUpdateFound
    return

  onUpdateFound: () =>
    $.off @installingRegistration, 'statechange', @onStateChange() if @installingRegistration
    @installingRegistration = @registration.installing
    $.on @installingRegistration, 'statechange', @onStateChange
    return

  onStateChange: () =>
    if @installingRegistration and @installingRegistration.state == 'installed' and navigator.serviceWorker.controller
      @installingRegistration = null
      @onUpdateReady()
    return

  onUpdateReady: ->
    @trigger 'updateready' if @notifyUpdate
    return
