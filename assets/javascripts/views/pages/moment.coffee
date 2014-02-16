#= require views/pages/base

class app.views.MomentPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre'), 'javascript'
    return
