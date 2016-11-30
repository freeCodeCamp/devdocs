#= require views/pages/base

class app.views.CodeceptionPage extends app.views.BasePage
  LANGUAGE_RGX = /language-(\w+)/

  prepare: ->
    for el in @findAll('pre > code')
      if el.className.match(LANGUAGE_RGX)
          @highlightCode(el, el.className.match(LANGUAGE_RGX)[1])
    return
