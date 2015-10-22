#= require views/pages/base

class app.views.ElixirPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.elixir'), 'elixir'
    return
