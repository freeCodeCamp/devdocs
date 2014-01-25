class app.views.SearchScope extends app.View
  SEARCH_PARAM = app.config.search_param

  @elements:
    input: '._search-input'
    tag:   '._search-tag'

  @events:
    keydown: 'onKeydown'

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

  search: (value) ->
    unless @doc
      @searcher.find app.docs.all(), 'slug', value
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
    @doc = doc

    @tag.textContent = doc.name
    @tag.style.display = 'block'

    @input.removeAttribute 'placeholder'
    @input.value = @input.value[@input.selectionStart..]
    @input.style.paddingLeft = @tag.offsetWidth + 6 + 'px'
    $.trigger @input, 'input'

  reset: =>
    @doc = null

    @tag.textContent = ''
    @tag.style.display = 'none'

    @input.setAttribute 'placeholder', @placeholder
    @input.style.paddingLeft = ''

  onKeydown: (event) =>
    return if event.ctrlKey or event.metaKey or event.altKey or event.shiftKey

    if event.which is 8 # backspace
      if @doc and not @input.value
        $.stopEvent(event)
        @reset()
    else if event.which is 9 or # tab
            event.which is 32 and (app.isMobile() or $.isTouchScreen()) # space
      $.stopEvent(event)
      @search @input.value[0...@input.selectionStart]
    return

  extractHashValue: ->
    if value = @getHashValue()
      newHash = $.urlDecode(location.hash).replace "##{SEARCH_PARAM}=#{value} ", "##{SEARCH_PARAM}="
      app.router.replaceHash(newHash)
      value

  getHashValue: ->
    try (new RegExp "^##{SEARCH_PARAM}=(.+?) .").exec($.urlDecode location.hash)?[1] catch
