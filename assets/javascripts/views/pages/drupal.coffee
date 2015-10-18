#= require views/pages/base

class app.views.DrupalPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.php'), 'php'
    return
