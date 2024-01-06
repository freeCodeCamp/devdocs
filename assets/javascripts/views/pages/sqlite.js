#= require views/pages/base

class app.views.SqlitePage extends app.views.BasePage
  @events:
    click: 'onClick'

  onClick: (event) =>
    return unless id = event.target.getAttribute('data-toggle')
    return unless el = @find("##{id}")
    $.stopEvent(event)
    if el.style.display == 'none'
      el.style.display = 'block'
      event.target.textContent = 'hide'
    else
      el.style.display = 'none'
      event.target.textContent = 'show'
    return
