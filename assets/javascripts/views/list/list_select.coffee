class app.views.ListSelect extends app.View
  @activeClass: 'active'

  @events:
    click: 'onClick'

  constructor: (@el) -> super

  deactivate: ->
    @deselect() if super
    return

  select: (el) ->
    @deselect()
    if el
      el.classList.add @constructor.activeClass
      $.trigger el, 'select'
    return

  deselect: ->
    if selection = @getSelection()
      selection.classList.remove @constructor.activeClass
      $.trigger selection, 'deselect'
    return

  selectByHref: (href) ->
    unless @getSelection()?.getAttribute('href') is href
      @select @find("a[href='#{href}']")
    return

  selectCurrent: ->
    @selectByHref location.pathname + location.hash
    return

  getSelection: ->
    @findByClass @constructor.activeClass

  onClick: (event) =>
    if event.target.tagName is 'A'
      @select event.target
    return
