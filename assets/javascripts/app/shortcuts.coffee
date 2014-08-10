class app.Shortcuts
  $.extend @prototype, Events

  constructor: ->
    @isWindows = $.isWindows()
    @start()

  start: ->
    $.on document, 'keydown', @onKeydown
    $.on document, 'keypress', @onKeypress
    return

  stop: ->
    $.off document, 'keydown', @onKeydown
    $.off document, 'keypress', @onKeypress
    return

  onKeydown: (event) =>
    result = if event.ctrlKey or event.metaKey
      @handleKeydownSuperEvent event unless event.altKey or event.shiftKey
    else if event.shiftKey
      @handleKeydownShiftEvent event unless event.altKey
    else if event.altKey
      @handleKeydownAltEvent event
    else
      @handleKeydownEvent event

    event.preventDefault() if result is false
    return

  onKeypress: (event) =>
    unless event.ctrlKey or event.metaKey
      result = @handleKeypressEvent event
      event.preventDefault() if result is false
    return

  handleKeydownEvent: (event) ->
    if not event.target.form and 65 <= event.which <= 90
      @trigger 'typing'
      return

    switch event.which
      when 8
        @trigger 'typing' unless event.target.form
      when 13
        @trigger 'enter'
      when 27
        @trigger 'escape'
      when 32
        @trigger 'pageDown'
        false
      when 33
        @trigger 'pageUp'
      when 34
        @trigger 'pageDown'
      when 35
        @trigger 'end'
      when 36
        @trigger 'home'
      when 37
        @trigger 'left' unless event.target.value
      when 38
        @trigger 'up'
        false
      when 39
        @trigger 'right' unless event.target.value
      when 40
        @trigger 'down'
        false

  handleKeydownSuperEvent: (event) ->
    switch event.which
      when 13
        @trigger 'superEnter'
      when 37
        unless @isWindows
          @trigger 'superLeft'
          false
      when 38
        @trigger 'home'
        false
      when 39
        unless @isWindows
          @trigger 'superRight'
          false
      when 40
        @trigger 'end'
        false

  handleKeydownShiftEvent: (event) ->
    if not event.target.form and 65 <= event.which <= 90
      @trigger 'typing'
      return

    if event.which is 32
      @trigger 'pageUp'
      false

  handleKeydownAltEvent: (event) ->
    switch event.which
      when 9
        @trigger 'altRight', event
      when 37
        if @isWindows
          @trigger 'superLeft'
          false
      when 38
        @trigger 'altUp'
        false
      when 39
        if @isWindows
          @trigger 'superRight'
          false
      when 40
        @trigger 'altDown'
        false
      when 70
        @trigger 'altF', event
      when 71
        @trigger 'altG'
        false
      when 82
        @trigger 'altR'
        false

  handleKeypressEvent: (event) ->
    if event.which is 63 and not event.target.value
      @trigger 'help'
      false
