class app.views.Menu extends app.View
  @el: '._menu'
  @activeClass: 'active'

  @events:
    click: 'onClick'

  init: ->
    $.on document.body, 'click', @onGlobalClick
    return

  onClick: =>
    prev = @el.previousElementSibling
    $.remove @el
    @delay (=> $.after prev, @el), 200
    return

  onGlobalClick: (event) =>
    return if event.which isnt 1
    if event.target.hasAttribute?('data-toggle-menu')
      @toggleClass @constructor.activeClass
    else if @hasClass @constructor.activeClass
      @removeClass @constructor.activeClass
    return
