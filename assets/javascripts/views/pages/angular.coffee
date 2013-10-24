#= require views/pages/base

class app.views.AngularPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByClass('prettyprint'), 'javascript'
    return
