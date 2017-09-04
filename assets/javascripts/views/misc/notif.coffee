class app.views.Notif extends app.View
  @className: '_notif'
  @activeClass: '_in'
  @attributes:
    role: 'alert'

  @defautOptions:
    autoHide: 15000

  @events:
    click: 'onClick'

  constructor: (@type, @options = {}) ->
    @options = $.extend {}, @constructor.defautOptions, @options
    super

  init: ->
    @show()
    return

  show: ->
    if @timeout
      clearTimeout @timeout
      @timeout = @delay @hide, @options.autoHide
    else
      @render()
      @position()
      @activate()
      @appendTo document.body
      @el.offsetWidth # force reflow
      @addClass @constructor.activeClass
      @timeout = @delay @hide, @options.autoHide if @options.autoHide
    return

  hide: ->
    clearTimeout @timeout
    @timeout = null
    @detach()
    return

  render: ->
    @html @tmpl("notif#{@type}")
    return

  position: ->
    notifications = $$ ".#{app.views.Notif.className}"
    if notifications.length
      lastNotif = notifications[notifications.length - 1]
      @el.style.top = lastNotif.offsetTop + lastNotif.offsetHeight + 16 + 'px'
    return

  onClick: (event) =>
    return if event.which isnt 1
    target = $.eventTarget(event)
    return if target.hasAttribute('data-behavior')
    if target.tagName isnt 'A' or target.classList.contains('_notif-close')
      $.stopEvent(event)
      @hide()
    return
