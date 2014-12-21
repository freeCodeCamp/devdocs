#= require views/pages/base

class app.views.ReactPage extends app.views.BasePage
  afterRender: ->
    for el in @findAllByTag 'pre'
      switch el.getAttribute('data-lang')
        when 'html' then @highlightCode el, 'markup'
        when 'javascript' then @highlightCode el, 'javascript'
    return
