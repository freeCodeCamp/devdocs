class app.views.BasePage extends app.View
  constructor: (@el, @entry) -> super

  render: (content) ->
    @addClass "_#{@entry.doc.type}" unless @constructor.className
    @html content
    @activate()
    @delay @afterRender if @afterRender
    return

  highlightCode: (el, language) ->
    if $.isCollection(el)
      @highlightCode e, language for e in el
    else if el
      el.classList.add "language-#{language}"
      Prism.highlightElement(el)
    return
