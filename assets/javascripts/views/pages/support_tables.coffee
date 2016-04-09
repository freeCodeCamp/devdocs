#= require views/pages/base

class app.views.SupportTablesPage extends app.views.BasePage
  @events:
    click: 'onClick'

  onClick: (event) ->
    return unless event.target.classList.contains 'show-all'
    $.stopEvent(event)

    el = event.target
    el = el.parentNode until el.tagName is 'TABLE'
    el.classList.add 'show-all'
    return
