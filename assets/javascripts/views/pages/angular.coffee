#= require views/pages/base

class app.views.AngularPage extends app.views.BasePage
  prepare: ->
    for el in @findAllByTag('pre')
      lang = if el.classList.contains('lang-html') or el.textContent[0] is '<'
        'markup'
      else if el.classList.contains('lang-css')
        'css'
      else
        'javascript'
      el.setAttribute('class', '')
      @highlightCode el, lang
    return
