#= require views/pages/base

class app.views.PhpunitPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('pre.programlisting'), 'php'
    return
