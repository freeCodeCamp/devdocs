#= require views/pages/base

class app.views.YiiPage extends app.views.BasePage
  @events:
    click: 'onClick'

  onClick: (event) ->
    return unless event.target.classList.contains 'show'
    $.stopEvent(event)

    source = $ '.code', event.target.parentNode.parentNode
    isShown = source.style.display is 'block'

    source.style.display = if isShown then 'none' else 'block'
    event.target.textContent = if isShown then 'show' else 'hide'
