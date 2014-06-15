#= require views/pages/base

class app.views.RequirejsPage extends app.views.BasePage
  afterRender: ->
    for el in @findAllByTag 'pre'
      language = if el.textContent.match(/^\s*</)
        'markup'
      else
        'javascript'
      @highlightCode el, language
    return
