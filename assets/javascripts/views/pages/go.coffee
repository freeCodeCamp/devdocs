#= require views/pages/base

class app.views.GoPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre'), 'go'
    return
