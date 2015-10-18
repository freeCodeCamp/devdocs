#= require views/pages/base

class app.views.EmberPage extends app.views.BasePage
  prepare: ->
    for el in @findAllByTag 'pre'
      language = if el.classList.contains 'javascript'
        'javascript'
      else if el.classList.contains 'html'
        'markup'
      @highlightCode el, language if language
    return
