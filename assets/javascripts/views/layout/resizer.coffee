class app.views.Resizer extends app.View
  @className: '_resizer'

  @events:
    dragstart: 'onDragStart'
    dragend: 'onDragEnd'

  @isSupported: ->
    'ondragstart' of document.createElement('div') and !app.isMobile()

  init: ->
    @el.setAttribute('draggable', 'true')
    @appendTo $('._app')
    return

  MIN = 260
  MAX = 600

  resize: (value, save) ->
    value -= app.el.offsetLeft
    return unless value > 0
    value = Math.min(Math.max(Math.round(value), MIN), MAX)
    newSize = "#{value}px"
    document.documentElement.style.setProperty('--sidebarWidth', newSize)
    app.settings.setSize(value) if save
    return

  onDragStart: (event) =>
    event.dataTransfer.effectAllowed = 'link'
    event.dataTransfer.setData('Text', '')
    $.on(window, 'dragover', @onDrag)
    return

  onDrag: (event) =>
    value = event.pageX
    return unless value > 0
    @lastDragValue = value
    return if @lastDrag and @lastDrag > Date.now() - 50
    @lastDrag = Date.now()
    @resize(value, false)
    return

  onDragEnd: (event) =>
    $.off(window, 'dragover', @onDrag)
    value = event.pageX or (event.screenX - window.screenX)
    if @lastDragValue and not (@lastDragValue - 5 < value < @lastDragValue + 5) # https://github.com/freeCodeCamp/devdocs/issues/265
      value = @lastDragValue
    @resize(value, true)
    return
