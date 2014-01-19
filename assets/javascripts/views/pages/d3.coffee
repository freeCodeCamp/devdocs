#= require views/pages/base

class app.views.D3Page extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('.highlight > pre'), 'javascript'
    return
