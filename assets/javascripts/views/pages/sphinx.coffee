#= require views/pages/base

class app.views.SphinxPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.python'), 'python'
    @highlightCode @findAll('pre.markup'), 'markup'
    @highlightCode @findAll('pre.php'), 'php'
    return
