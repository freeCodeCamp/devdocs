class app.views.Resizer extends app.View
  @className: '_resizer'

  @events:
    dragstart: 'onDragStart'
    dragend: 'onDragEnd'
    drag: 'onDrag'

  @isSupported: ->
    'ondragstart' of document.createElement('div') and !app.isMobile()

  init: ->
    @el.setAttribute('draggable', 'true')
    @appendTo $('._app')

    @style = $('style[data-resizer]')
    @size = @style.getAttribute('data-size')
    return

  MIN = 260
  MAX = 600

  resize: (value, save) ->
    value -= app.el.offsetLeft
    return unless value > 0
    value = Math.min(Math.max(Math.round(value), MIN), MAX)
    newSize = "#{value}px"
    @style.innerHTML = @style.innerHTML.replace(new RegExp(@size, 'g'), newSize)
    @size = newSize
    if save
      app.settings.setSize(value)
      app.appCache?.updateInBackground()
    return

  onDragStart: (event) =>
    @style.removeAttribute('disabled')
    event.dataTransfer.effectAllowed = 'link'
    event.dataTransfer.setData('Text', '')
    return

  onDrag: (event) =>
    return if @lastDrag and @lastDrag > Date.now() - 50
    @lastDrag = Date.now()
    @resize(event.pageX, false)
    return

  onDragEnd: (event) =>
    @resize(event.pageX or (event.screenX - window.screenX), true)
    return
