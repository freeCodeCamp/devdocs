#= require views/pages/base

class app.views.PhpPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByClass('phpcode'), 'php'
    return
