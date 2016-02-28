#= require views/pages/base

class app.views.GithubPage extends app.views.BasePage
  LANGUAGE_RGX = /highlight-source-(\w+)/

  prepare: ->
    for el in @findAll('pre.highlight')
      @highlightCode(el, el.className.match(LANGUAGE_RGX)[1])
    return
