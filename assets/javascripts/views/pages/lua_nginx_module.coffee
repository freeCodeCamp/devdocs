#= require views/pages/base

# this may be used for all GitHub pages

class app.views.LuaNginxModulePage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('div.highlight-source-lua pre'), 'lua'
    return
