#= require views/pages/base

class app.views.CrystalPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'ruby'
    return
