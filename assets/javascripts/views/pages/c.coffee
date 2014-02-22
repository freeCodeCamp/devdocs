#= require views/pages/base

class app.views.CPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.source-c, .source-c > pre'), 'c'
    return
