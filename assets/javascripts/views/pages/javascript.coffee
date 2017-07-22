#= require views/pages/base

class app.views.JavascriptWithMarkupCheckPage extends app.views.BasePage
  prepare: ->
    for el in @findAllByTag('pre')
      language = if el.textContent.match(/^\s*</)
        'markup'
      else
        'javascript'
      @highlightCode el, language
    return

app.views.DojoPage =
app.views.JavascriptWithMarkupCheckPage
