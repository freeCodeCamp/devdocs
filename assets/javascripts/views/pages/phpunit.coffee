#= require views/pages/base

class app.views.PhpunitPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre.programlisting'), 'php'
    return
