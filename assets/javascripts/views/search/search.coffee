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
    altS: 'stackoverflow'

  @routes:
    root: 'onRoot'
    after: 'afterRoute'

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
    @delay =>
      @input.focus() unless document.activeElement is @input
    return

  autoFocus: =>
    unless app.isMobile() or $.isAndroid() or $.isIOS()
      @input.focus() unless document.activeElement?.tagName is 'INPUT'
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
    if app.router.isRoot()
      @scope.searchUrl()
    else if not app.router.isDocIndex()
      return

    return unless value = @extractHashValue()
    @input.value = @value = value
    @input.setSelectionRange(value.length, value.length)
    @search true
    true

  clear: ->
    @removeClass @constructor.activeClass
    @trigger 'clear'
    return

  externalSearch: (url) ->
    if value = @value
      value = "#{@scope.name()} #{value}" if @scope.name()
      $.popup "#{url}#{encodeURIComponent value}"
      @reset()
    return

  google: =>
    @externalSearch "https://www.google.com/search?q="
    return

  stackoverflow: =>
    @externalSearch "https://stackoverflow.com/search?q="
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
      app.document.onEscape()
    return

  onSubmit: (event) ->
    $.stopEvent(event)
    return

  onRoot: (context) =>
    @reset() unless context.init
    return

  afterRoute: (name, context) =>
    @delay @searchUrl if context.hash
    @delay @autoFocus
    return

  extractHashValue: ->
    if (value = @getHashValue())?
      app.router.replaceHash()
      value

  HASH_RGX = new RegExp "^##{SEARCH_PARAM}=(.*)"

  getHashValue: ->
    try HASH_RGX.exec($.urlDecode location.hash)?[1] catch
