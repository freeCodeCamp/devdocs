#= require views/pages/base

class app.views.VagrantPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.ruby'), 'ruby'
