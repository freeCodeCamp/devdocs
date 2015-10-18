#= require views/pages/base

class app.views.KnockoutPage extends app.views.BasePage
  prepare: ->
    for el in @findAll('pre')
      language = if el.innerHTML.indexOf('data-bind="') > 0 then 'markup' else 'javascript'
      @highlightCode el, language
    return
