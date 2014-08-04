#= require views/pages/base

class app.views.SphinxPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.python'), 'python'
    @highlightCode @findAll('pre.markup'), 'markup'
    return
