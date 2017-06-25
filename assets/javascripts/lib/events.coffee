@Events =
  on: (event, callback) ->
    if event.indexOf(' ') >= 0
      @on name, callback for name in event.split(' ')
    else
      ((@_callbacks ?= {})[event] ?= []).push callback
    @

  off: (event, callback) ->
    if event.indexOf(' ') >= 0
      @off name, callback for name in event.split(' ')
    else if (callbacks = @_callbacks?[event]) and (index = callbacks.indexOf callback) >= 0
      callbacks.splice index, 1
      delete @_callbacks[event] unless callbacks.length
    @

  trigger: (event, args...) ->
    @eventInProgress = { name: event, args: args }
    if callbacks = @_callbacks?[event]
      callback? args... for callback in callbacks.slice(0)
    @eventInProgress = null
    @trigger 'all', event, args... unless event is 'all'
    @

  removeEvent: (event) ->
    if @_callbacks?
      delete @_callbacks[name] for name in event.split(' ')
    @
