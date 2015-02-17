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

  MIN = 250
  MAX = 600

  resize: (newSize) ->
    return unless newSize > 0
    newSize = Math.min(Math.max(Math.round(newSize), MIN), MAX)
    app.settings.setSize(newSize)
    newSize = "#{newSize}px"
    @style.innerHTML = @style.innerHTML.replace(new RegExp(@size, 'g'), newSize)
    @size = newSize
    return

  onDragStart: (event) =>
    @style.removeAttribute('disabled')
    event.dataTransfer.effectAllowed = 'link'
    event.dataTransfer.setData('text/plain', '')
    return

  onDrag: (event) =>
    return if @lastDrag and @lastDrag > Date.now() - 50
    @lastDrag = Date.now()
    @resize event.clientX
    return

  onDragEnd: (event) =>
    @resize event.screenX - window.screenX
    return
