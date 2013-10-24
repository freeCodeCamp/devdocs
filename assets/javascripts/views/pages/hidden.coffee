class app.views.HiddenPage extends app.View
  @events:
    click: 'onClick'

  constructor: (@el, @entry) -> super

  init: ->
    @addSubview @notice = new app.views.Notice 'disabledDoc'
    @activate()
    return

  onClick: (event) =>
    if link = $.closestLink(event.target, @el)
      $.stopEvent(event)
      $.popup(link)
    return
