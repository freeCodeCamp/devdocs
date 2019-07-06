class app.ServiceWorker
  $.extend @prototype, Events

  @isEnabled: ->
    !!navigator.serviceWorker

  constructor: ->
    @registration = null
    @installingRegistration = null
    @notifyUpdate = true

    navigator.serviceWorker.register(app.config.service_worker_path, {scope: '/'})
      .then((registration) => @updateRegistration(registration))
      .catch((error) -> console.error 'Could not register service worker:', error)

  update: ->
    return unless @registration
    @notifyUpdate = true
    return @doUpdate()

  updateInBackground: ->
    return unless @registration
    @notifyUpdate = false
    return @doUpdate()

  reload: ->
    return @updateInBackground().then(() -> app.reboot())

  doUpdate: ->
    return @registration.update().catch(->)

  updateRegistration: (registration) ->
    $.off @registration, 'updatefound', @onUpdateFound if @registration
    $.off @installingRegistration, 'statechange', @onStateChange if @installingRegistration

    @registration = registration
    @installingRegistration = null

    $.on @registration, 'updatefound', @onUpdateFound
    return

  onUpdateFound: () =>
    @installingRegistration = @registration.installing
    $.on @installingRegistration, 'statechange', @onStateChange
    return

  onStateChange: () =>
    if @installingRegistration.state == 'installed' and navigator.serviceWorker.controller
      @updateRegistration(@installingRegistration)
      @onUpdateReady()
    return

  onUpdateReady: ->
    @trigger 'updateready' if @notifyUpdate
    return
