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
    return @handleKeydownAltEvent(event, true) if not _force and event.key in ['ArrowLeft', 'ArrowUp', 'ArrowRight', 'ArrowDown'] and @swapArrowKeysBehavior()

    if not event.target.form and (event.key.length is 1 and ('0' <= event.key <= '9' or 'A' <= event.key <= 'z'))
      @trigger 'typing'
      return

    switch event.key
      when 'Backspace'
        @trigger 'typing' unless event.target.form
      when 'Enter'
        @trigger 'enter'
      when 'Escape'
        @trigger 'escape'
        false
      when ' '
        if event.target.type is 'search' and (not @lastKeypress or @lastKeypress < Date.now() - 500)
          @trigger 'pageDown'
          false
      when 'PageUp'
        @trigger 'pageUp'
      when 'PageDown'
        @trigger 'pageDown'
      when 'End'
        @trigger 'pageBottom' unless event.target.form
      when 'Home'
        @trigger 'pageTop' unless event.target.form
      when 'ArrowLeft'
        @trigger 'left' unless event.target.value
      when 'ArrowUp'
        @trigger 'up'
        @showTip?()
        false
      when 'ArrowRight'
        @trigger 'right' unless event.target.value
      when 'ArrowDown'
        @trigger 'down'
        @showTip?()
        false
      when '/'
        unless event.target.form
          @trigger 'typing'
          false

  handleKeydownSuperEvent: (event) ->
    switch event.key
      when 'Enter'
        @trigger 'superEnter'
      when 'ArrowLeft'
        if @isMac
          @trigger 'superLeft'
          false
      when 'ArrowUp'
        @trigger 'pageTop'
        false
      when 'ArrowRight'
        if @isMac
          @trigger 'superRight'
          false
      when 'ArrowDown'
        @trigger 'pageBottom'
        false
      when ','
        @trigger 'preferences'
        false

  handleKeydownShiftEvent: (event, _force) ->
    return @handleKeydownEvent(event, true) if not _force and event.key in ['ArrowLeft', 'ArrowUp', 'ArrowRight', 'ArrowDown'] and @swapArrowKeysBehavior()

    if not event.target.form and (event.key.length is 1 and 'A' <= event.key <= 'z')
      @trigger 'typing'
      return

    switch event.key
      when ' '
        @trigger 'pageUp'
        false
      when 'ArrowUp'
        unless getSelection()?.toString()
          @trigger 'altUp'
          false
      when 'ArrowDown'
        unless getSelection()?.toString()
          @trigger 'altDown'
          false

  handleKeydownAltEvent: (event, _force) ->
    return @handleKeydownEvent(event, true) if not _force and event.key in ['ArrowLeft', 'ArrowUp', 'ArrowRight', 'ArrowDown'] and @swapArrowKeysBehavior()

    switch event.key
      when 'Tab'
        @trigger 'altRight', event
      when 'ArrowLeft'
        unless @isMac
          @trigger 'superLeft'
          false
      when 'ArrowUp'
        @trigger 'altUp'
        false
      when 'ArrowRight'
        unless @isMac
          @trigger 'superRight'
          false
      when 'ArrowDown'
        @trigger 'altDown'
        false
      when 'f'
        @trigger 'altF', event
      when 'g'
        @trigger 'altG'
        false
      when 'o'
        @trigger 'altO'
        false
      when 'r'
        @trigger 'altR'
        false
      when 's'
        @trigger 'altS'
        false

  handleKeypressEvent: (event) ->
    if event.key is '?' and not event.target.value
      @trigger 'help'
      false
    else
      @lastKeypress = Date.now()

  buggyEvent: (event) ->
    try
      event.target
      event.ctrlKey
      event.key
      return false
    catch
      return true
