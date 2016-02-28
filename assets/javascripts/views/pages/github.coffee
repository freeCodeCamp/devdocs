#= require views/pages/base

class app.views.GithubPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.highlight-source-lua'), 'lua'
    return
