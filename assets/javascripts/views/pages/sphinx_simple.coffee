#= require views/pages/base

class app.views.SphinxSimplePage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.highlight-ruby'), 'ruby'
    @highlightCode @findAll('pre.highlight-javascript'), 'javascript'
    return
