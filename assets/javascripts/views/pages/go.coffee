#= require views/pages/base

class app.views.GoPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre'), 'go'
    return
