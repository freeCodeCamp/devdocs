#= require views/pages/base

class app.views.AngularPage extends app.views.BasePage
  afterRender: ->
    for el in @findAllByTag('pre')
      @highlightCode el, if el.textContent[0] is '<' then 'markup' else 'javascript'
    return
