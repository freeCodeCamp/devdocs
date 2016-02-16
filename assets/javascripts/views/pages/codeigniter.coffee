#= require views/pages/base

class app.views.CodeigniterPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'php'
    return
