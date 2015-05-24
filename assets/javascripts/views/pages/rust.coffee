#= require views/pages/base

class app.views.RustPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.rust'), 'rust'
    return
