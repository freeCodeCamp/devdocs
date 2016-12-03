#= require views/pages/base

class app.views.CodeceptjsPage extends app.views.BasePage

  prepare: ->
    for el in @findAll('pre > code')
      if /js/i.test(el.className)
          @highlightCode(el, 'javascript')
    return
