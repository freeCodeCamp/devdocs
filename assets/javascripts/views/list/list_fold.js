class app.views.ListFold extends app.View
  @targetClass: '_list-dir'
  @handleClass: '_list-arrow'
  @activeClass: 'open'

  @events:
    click: 'onClick'

  @shortcuts:
    left:   'onLeft'
    right:  'onRight'

  constructor: (@el) -> super

  open: (el) ->
    if el and not el.classList.contains @constructor.activeClass
      el.classList.add @constructor.activeClass
      $.trigger el, 'open'
    return

  close: (el) ->
    if el and el.classList.contains @constructor.activeClass
      el.classList.remove @constructor.activeClass
      $.trigger el, 'close'
    return

  toggle: (el) ->
    if el.classList.contains @constructor.activeClass
      @close el
    else
      @open el
    return

  reset: ->
    while el = @findByClass @constructor.activeClass
      @close el
    return

  getCursor: ->
    @findByClass(app.views.ListFocus.activeClass) or @findByClass(app.views.ListSelect.activeClass)

  onLeft: =>
    cursor = @getCursor()
    if cursor?.classList.contains @constructor.activeClass
      @close cursor
    return

  onRight: =>
    cursor = @getCursor()
    if cursor?.classList.contains @constructor.targetClass
      @open cursor
    return

  onClick: (event) =>
    return if event.which isnt 1 or event.metaKey or event.ctrlKey
    return unless event.pageY # ignore fabricated clicks
    el = $.eventTarget(event)
    el = el.parentNode if el.parentNode.tagName.toUpperCase() is 'SVG'

    if el.classList.contains @constructor.handleClass
      $.stopEvent(event)
      @toggle el.parentNode
    else if el.classList.contains @constructor.targetClass
      if el.hasAttribute('href')
        if el.classList.contains(@constructor.activeClass)
          @close(el) if el.classList.contains(app.views.ListSelect.activeClass)
        else
          @open(el)
      else
        @toggle(el)
    return
