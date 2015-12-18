#= require views/pages/base

class app.views.PerlPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'perl'
    return
