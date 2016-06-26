class app.views.SearchScope extends app.View
  SEARCH_PARAM = app.config.search_param

  @elements:
    input: '._search-input'
    tag:   '._search-tag'

  @events:
    keydown: 'onKeydown'

  @routes:
    after: 'afterRoute'

  @shortcuts:
    escape: 'reset'

  constructor: (@el) -> super

  init: ->
    @placeholder = @input.getAttribute 'placeholder'

    @searcher = new app.SynchronousSearcher
      fuzzy_min_length: 2
      max_results: 1
    @searcher.on 'results', @onResults

    return

  getScope: ->
    @doc or app

  name: ->
    @doc?.name

  search: (value) ->
    unless @doc
      @searcher.find app.docs.all(), 'text', value
    return

  searchUrl: ->
    if value = @extractHashValue()
      @search value
    return

  onResults: (results) =>
    if results.length
      @selectDoc results[0]
    return

  selectDoc: (doc) ->
    previousDoc = @doc
    return if doc is previousDoc
    @doc = doc

    @tag.textContent = doc.fullName
    @tag.style.display = 'block'

    @input.removeAttribute 'placeholder'
    @input.value = @input.value[@input.selectionStart..]
    @input.style.paddingLeft = @tag.offsetWidth + 10 + 'px'

    $.trigger @input, 'input'
    @trigger 'change', @doc, previousDoc
    return

  reset: =>
    return unless @doc
    previousDoc = @doc
    @doc = null

    @tag.textContent = ''
    @tag.style.display = 'none'

    @input.setAttribute 'placeholder', @placeholder
    @input.style.paddingLeft = ''

    @trigger 'change', null, previousDoc
    return

  onKeydown: (event) =>
    return if event.ctrlKey or event.metaKey or event.altKey or event.shiftKey

    if event.which is 8 # backspace
      if @doc and not @input.value
        $.stopEvent(event)
        @reset()
    else if not @doc and @input.value
      if event.which is 9 or # tab
         event.which is 32 and (app.isMobile() or $.isTouchScreen()) # space
        @search @input.value[0...@input.selectionStart]
        $.stopEvent(event) if @doc
    return

  extractHashValue: ->
    if value = @getHashValue()
      newHash = $.urlDecode(location.hash).replace "##{SEARCH_PARAM}=#{value} ", "##{SEARCH_PARAM}="
      app.router.replaceHash(newHash)
      value

  getHashValue: ->
    try (new RegExp "^##{SEARCH_PARAM}=(.+?) .").exec($.urlDecode location.hash)?[1] catch

  afterRoute: (name, context) =>
    if !app.isSingleDoc() and context.init and context.doc
      @selectDoc(context.doc)
    return
