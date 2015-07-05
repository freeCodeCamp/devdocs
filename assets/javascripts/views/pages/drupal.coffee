#= require views/pages/base

class app.views.DrupalPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.php'), 'php'
    return
