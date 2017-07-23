class app.views.BasePage extends app.View
  constructor: (@el, @entry) -> super

  deactivate: ->
    if super
      @highlightNodes = []

  render: (content, fromCache = false) ->
    @highlightNodes = []
    @previousTiming = null
    @addClass "_#{@entry.doc.type}" unless @constructor.className
    @html content
    @highlightCode() unless fromCache
    @activate()
    @delay @afterRender if @afterRender
    if @highlightNodes.length > 0
      $.requestAnimationFrame => $.requestAnimationFrame(@paintCode)
    return

  highlightCode: ->
    for el in @findAll('pre[data-language]')
      language = el.getAttribute('data-language')
      el.classList.add("language-#{language}")
      @highlightNodes.push(el)
    return

  paintCode: (timing) =>
    if @previousTiming
      if Math.round(1000 / (timing - @previousTiming)) > 50 # fps
        @nodesPerFrame = Math.round(Math.min(@nodesPerFrame * 1.25, 50))
      else
        @nodesPerFrame = Math.round(Math.max(@nodesPerFrame * .8, 10))
    else
      @nodesPerFrame = 10

    for el in @highlightNodes.splice(0, @nodesPerFrame)
      $.remove(clipEl) if clipEl = el.lastElementChild
      Prism.highlightElement(el)
      $.append(el, clipEl) if clipEl

    $.requestAnimationFrame(@paintCode) if @highlightNodes.length > 0
    @previousTiming = timing
    return
