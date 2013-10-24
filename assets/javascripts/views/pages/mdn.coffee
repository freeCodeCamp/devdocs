#= require views/pages/base

class app.views.MdnPage extends app.views.BasePage
  @className: '_mdn'

  LANGUAGE_REGEXP = /brush: ?(\w+)/

  afterRender: ->
    for el in @findAll 'pre[class^="brush"]'
      language = el.className.match(LANGUAGE_REGEXP)[1]
        .replace('html', 'markup')
        .replace('js', 'javascript')
      el.className = ''
      @highlightCode el, language
    return
