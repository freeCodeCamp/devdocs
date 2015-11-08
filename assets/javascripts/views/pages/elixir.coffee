#= require views/pages/base

class app.views.ElixirPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAllByTag('pre'), 'elixir'
    return
