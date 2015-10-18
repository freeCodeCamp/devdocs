#= require views/pages/base

class app.views.PhalconPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre[class*="php"]'), 'php'
    @highlightCode @findAll('pre.highlight-html'), 'markup'
    return
