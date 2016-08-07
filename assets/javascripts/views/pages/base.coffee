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
    @prepare?() unless fromCache
    @activate()
    @delay @afterRender if @afterRender
    $.requestAnimationFrame(@paintCode) if @highlightNodes.length > 0
    return

  highlightCode: (el, language) ->
    return unless language
    language = "language-#{language}"
    if $.isCollection(el)
      for e in el
        e.classList.add(language)
        @highlightNodes.push(e)
    else if el
      el.classList.add(language)
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
    Prism.highlightElement(el) for el in @highlightNodes.splice(0, @nodesPerFrame)
    $.requestAnimationFrame(@paintCode) if @highlightNodes.length > 0
    @previousTiming = timing
    return
