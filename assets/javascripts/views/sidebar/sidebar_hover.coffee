class app.views.SidebarHover extends app.View
  @itemClass: '_list-hover'

  @events:
    focus:     'onFocus'
    blur:      'onBlur'
    mouseover: 'onMouseover'
    mouseout:  'onMouseout'
    scroll:    'onScroll'
    click:     'onClick'

  @routes:
    after: 'onRoute'

  constructor: (@el) ->
    unless isPointerEventsSupported()
      delete @constructor.events.mouseover
    super

  show: (el) ->
    unless el is @cursor
      @hide()
      if @isTarget(el) and @isTruncated(el.lastElementChild or el)
        @cursor = el
        @clone = @makeClone @cursor
        $.append document.body, @clone
        @offsetTop ?= @el.offsetTop
        @position()
    return

  hide: ->
    if @cursor
      $.remove @clone
      @cursor = @clone = null
    return

  position: =>
    if @cursor
      rect = $.rect(@cursor)
      if rect.top >= @offsetTop
        @clone.style.top = rect.top + 'px'
        @clone.style.left = rect.left + 'px'
      else
        @hide()
    return

  makeClone: (el) ->
    clone = el.cloneNode(true)
    clone.classList.add 'clone'
    clone

  isTarget: (el) ->
    el?.classList?.contains @constructor.itemClass

  isSelected: (el) ->
    el.classList.contains 'active'

  isTruncated: (el) ->
    el.scrollWidth > el.offsetWidth

  onFocus: (event) =>
    @focusTime = Date.now()
    @show event.target
    return

  onBlur: =>
    @hide()
    return

  onMouseover: (event) =>
    if @isTarget(event.target) and not @isSelected(event.target) and @mouseActivated()
      @show event.target
    return

  onMouseout: (event) =>
    if @isTarget(event.target) and @mouseActivated()
      @hide()
    return

  mouseActivated: ->
    # Skip mouse events caused by focus events scrolling the sidebar.
    not @focusTime or Date.now() - @focusTime > 500

  onScroll: =>
    @position()
    return

  onClick: (event) =>
    if event.target is @clone
      $.click @cursor
    return

  onRoute: =>
    @hide()
    return

isPointerEventsSupported = ->
  el = document.createElement 'div'
  el.style.cssText = 'pointer-events: auto'
  el.style.pointerEvents is 'auto'
