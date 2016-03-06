#= require views/pages/base

class app.views.TensorflowPage extends app.views.BasePage
  prepare: ->
    @highlightCode @findAll('pre[class*="lang-c++"]'), 'cpp'
    @highlightCode @findAll('pre.lang-python'), 'python'
    return
