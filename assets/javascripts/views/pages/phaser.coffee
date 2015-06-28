#= require views/pages/base

class app.views.PhaserPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.source'), 'javascript'
    return
