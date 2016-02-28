#= require views/pages/base

class app.views.LuaPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'lua'
    return
