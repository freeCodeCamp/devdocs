#= require views/pages/base

class app.views.RustPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.rust'), 'rust'
    return
