class app.Shortcuts
  $.extend @prototype, Events

  constructor: ->
    @isMac = $.isMac()
    @start()

  start: ->
    $.on document, 'keydown', @onKeydown
    $.on document, 'keypress', @onKeypress
    return

  stop: ->
    $.off document, 'keydown', @onKeydown
    $.off document, 'keypress', @onKeypress
    return

  swapArrowKeysBehavior: ->
    app.settings.get('arrowScroll')

  showTip: ->
    app.showTip('KeyNav')
    @showTip = null

  onKeydown: (event) =>
    return if @buggyEvent(event)
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
    return if @buggyEvent(event)
    unless event.ctrlKey or event.metaKey
      result = @handleKeypressEvent event
      event.preventDefault() if result is false
    return

  handleKeydownEvent: (event, _force) ->
    return @handleKeydownAltEvent(event, true) if not _force and event.which in [37, 38, 39, 40] and @swapArrowKeysBehavior()

    if not event.target.form and (48 <= event.which <= 57 or 65 <= event.which <= 90)
      @trigger 'typing'
      return

    switch event.which
      when 8
        @trigger 'typing' unless event.target.form
      when 13
        @trigger 'enter'
      when 27
        @trigger 'escape'
        false
      when 32
        if event.target.type is 'search' and (not @lastKeypress or @lastKeypress < Date.now() - 500)
          @trigger 'pageDown'
          false
      when 33
        @trigger 'pageUp'
      when 34
        @trigger 'pageDown'
      when 35
        @trigger 'pageBottom' unless event.target.form
      when 36
        @trigger 'pageTop' unless event.target.form
      when 37
        @trigger 'left' unless event.target.value
      when 38
        @trigger 'up'
        @showTip?()
        false
      when 39
        @trigger 'right' unless event.target.value
      when 40
        @trigger 'down'
        @showTip?()
        false
      when 191
        unless event.target.form
          @trigger 'typing'
          false

  handleKeydownSuperEvent: (event) ->
    switch event.which
      when 13
        @trigger 'superEnter'
      when 37
        if @isMac
          @trigger 'superLeft'
          false
      when 38
        @trigger 'pageTop'
        false
      when 39
        if @isMac
          @trigger 'superRight'
          false
      when 40
        @trigger 'pageBottom'
        false
      when 188
        @trigger 'preferences'
        false

  handleKeydownShiftEvent: (event, _force) ->
    return @handleKeydownEvent(event, true) if not _force and event.which in [37, 38, 39, 40] and @swapArrowKeysBehavior()

    if not event.target.form and 65 <= event.which <= 90
      @trigger 'typing'
      return

    switch event.which
      when 32
        @trigger 'pageUp'
        false
      when 38
        unless getSelection()?.toString()
          @trigger 'altUp'
          false
      when 40
        unless getSelection()?.toString()
          @trigger 'altDown'
          false

  handleKeydownAltEvent: (event, _force) ->
    return @handleKeydownEvent(event, true) if not _force and event.which in [37, 38, 39, 40] and @swapArrowKeysBehavior()

    switch event.which
      when 9
        @trigger 'altRight', event
      when 37
        unless @isMac
          @trigger 'superLeft'
          false
      when 38
        @trigger 'altUp'
        false
      when 39
        unless @isMac
          @trigger 'superRight'
          false
      when 40
        @trigger 'altDown'
        false
      when 68
        @trigger 'altD'
        false
      when 70
        @trigger 'altF', event
      when 71
        @trigger 'altG'
        false
      when 79
        @trigger 'altO'
        false
      when 82
        @trigger 'altR'
        false
      when 83
        @trigger 'altS'
        false

  handleKeypressEvent: (event) ->
    if event.which is 63 and not event.target.value
      @trigger 'help'
      false
    else
      @lastKeypress = Date.now()

  buggyEvent: (event) ->
    try
      event.target
      event.ctrlKey
      event.which
      return false
    catch
      return true
