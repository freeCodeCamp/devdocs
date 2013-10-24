#= require views/pages/base

class app.views.NodePage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre > code'), 'javascript'
    return
