#= require views/pages/base

class app.views.QPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('.highlight-js > pre'), 'javascript'
    return
