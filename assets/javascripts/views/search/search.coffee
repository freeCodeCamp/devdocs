class app.views.Search extends app.View
  SEARCH_PARAM = app.config.search_param

  @el: '._search'
  @activeClass: '_search-active'

  @elements:
    input:     '._search-input'
    resetLink: '._search-clear'

  @events:
    input:  'onInput'
    click:  'onClick'
    submit: 'onSubmit'

  @shortcuts:
    typing: 'autoFocus'
    altG: 'google'

  @routes:
    root: 'onRoot'
    after: 'autoFocus'

  init: ->
    @addSubview @scope = new app.views.SearchScope @el

    @searcher = new app.Searcher
    @searcher
      .on 'results', @onResults
      .on 'end', @onEnd

    app.on 'ready', @onReady
    $.on window, 'hashchange', @searchUrl
    $.on window, 'focus', @autoFocus
    return

  focus: ->
    @input.focus() unless document.activeElement is @input
    return

  autoFocus: =>
    @focus() unless $.isTouchScreen()
    return

  reset: ->
    @el.reset()
    @onInput()
    @autoFocus()
    return

  onReady: =>
    @value = ''
    @delay @onInput
    return

  onInput: =>
    return if not @value? or # ignore events pre-"ready"
              @value is @input.value
    @value = @input.value

    if @value.length
      @search()
    else
      @clear()
    return

  search: (url = false) ->
    @addClass @constructor.activeClass
    @trigger 'searching'

    @hasResults = null
    @flags = urlSearch: url, initialResults: true
    @searcher.find @scope.getScope().entries.all(), 'text', @value
    return

  searchUrl: =>
    return unless app.router.isRoot()
    @scope.searchUrl()

    return unless value = @extractHashValue()
    @input.value = @value = value
    @search true
    true

  clear: ->
    @removeClass @constructor.activeClass
    @trigger 'clear'

  google: =>
    if @value
      $.popup "https://www.google.com/search?q=#{encodeURIComponent @value}"
      @reset()
    return

  onResults: (results) =>
    @hasResults = true if results.length
    @trigger 'results', results, @flags
    @flags.initialResults = false
    return

  onEnd: =>
    @trigger 'noresults' unless @hasResults
    return

  onClick: (event) =>
    if event.target is @resetLink
      $.stopEvent(event)
      @reset()
      @focus()
    return

  onSubmit: (event) ->
    $.stopEvent(event)
    return

  onRoot: (context) =>
    @reset() unless context.init
    @delay @searchUrl if context.hash
    return

  extractHashValue: ->
    if (value = @getHashValue())?
      app.router.replaceHash()
      value

  getHashValue: ->
    try (new RegExp "##{SEARCH_PARAM}=(.*)").exec($.urlDecode location.hash)?[1] catch
