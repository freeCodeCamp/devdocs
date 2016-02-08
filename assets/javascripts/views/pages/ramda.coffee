#= require views/pages/base

class app.views.RamdaPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('section > pre:last-child'), 'javascript'
    return
