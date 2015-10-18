#= require views/pages/base

class app.views.LaravelPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'php'
    return
