#= require views/pages/base

class app.views.CakephpPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'php'
    return
