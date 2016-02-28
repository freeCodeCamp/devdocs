#= require views/pages/base

class app.views.NginxPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'nginx'
    return
