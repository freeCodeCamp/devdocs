#= require views/pages/base

class app.views.LaravelPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByTag('pre'), 'php'
    return
