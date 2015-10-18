#= require views/pages/base

class app.views.PhpPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByClass('phpcode'), 'php'
    return
