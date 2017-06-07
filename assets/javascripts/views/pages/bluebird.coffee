#= require views/pages/base

class app.views.BluebirdPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAllByClass('language-javascript'), 'javascript'
    return