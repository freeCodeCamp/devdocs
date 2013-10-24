#= require views/pages/base

class app.views.UnderscorePage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByTag('pre'), 'javascript'
    return
