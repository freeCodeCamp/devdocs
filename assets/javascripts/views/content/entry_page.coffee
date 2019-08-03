class app.views.EntryPage extends app.View
  @className: '_page'
  @errorClass: '_page-error'

  @events:
    click: 'onClick'

  @shortcuts:
    altO: 'onAltO'

  @routes:
    before: 'beforeRoute'

  init: ->
    @cacheMap = {}
    @cacheStack = []
    return

  deactivate: ->
    if super
      @empty()
      @entry = null
    return

  loading: ->
    @empty()
    @trigger 'loading'
    return

  render: (content = '', fromCache = false) ->
    return unless @activated
    @empty()
    @subview = new (@subViewClass()) @el, @entry

    $.batchUpdate @el, =>
      @subview.render(content, fromCache)
      @addCopyButtons() unless fromCache
      return

    if app.disabledDocs.findBy 'slug', @entry.doc.slug
      @hiddenView = new app.views.HiddenPage @el, @entry

    setFaviconForDoc(@entry.doc)
    @delay @polyfillMathML
    @trigger 'loaded'
    return

  addCopyButtons: ->
    unless @copyButton
      @copyButton = document.createElement('button')
      @copyButton.innerHTML = '<svg><use xlink:href="#icon-copy"/></svg>'
      @copyButton.type = 'button'
      @copyButton.className = '_pre-clip'
      @copyButton.title = 'Copy to clipboard'
      @copyButton.setAttribute 'aria-label', 'Copy to clipboard'
    el.appendChild @copyButton.cloneNode(true) for el in @findAllByTag('pre')
    return

  polyfillMathML: ->
    return unless window.supportsMathML is false and !@polyfilledMathML and @findByTag('math')
    @polyfilledMathML = true
    $.append document.head, """<link rel="stylesheet" href="#{app.config.mathml_stylesheet}">"""
    return

  LINKS =
    home: 'Homepage'
    code: 'Source code'

  prepareContent: (content) ->
    return content unless @entry.isIndex() and @entry.doc.links

    links = for link, url of @entry.doc.links
      """<a href="#{url}" class="_links-link">#{LINKS[link]}</a>"""

    """<p class="_links">#{links.join('')}</p>#{content}"""

  empty: ->
    @subview?.deactivate()
    @subview = null

    @hiddenView?.deactivate()
    @hiddenView = null

    @resetClass()
    super
    return

  subViewClass: ->
    app.views["#{$.classify(@entry.doc.type)}Page"] or app.views.BasePage

  getTitle: ->
    @entry.doc.fullName + if @entry.isIndex() then ' documentation' else " / #{@entry.name}"

  beforeRoute: =>
    @cache()
    @abort()
    return

  onRoute: (context) ->
    isSameFile = context.entry.filePath() is @entry?.filePath()
    @entry = context.entry
    @restore() or @load() unless isSameFile
    return

  load: ->
    @loading()
    @xhr = @entry.loadFile @onSuccess, @onError
    return

  abort: ->
    if @xhr
      @xhr.abort()
      @xhr = @entry = null
    return

  onSuccess: (response) =>
    return unless @activated
    @xhr = null
    @render @prepareContent(response)
    return

  onError: =>
    @xhr = null
    @render @tmpl('pageLoadError')
    @resetClass()
    @addClass @constructor.errorClass
    app.serviceWorker?.update()
    return

  cache: ->
    return if @xhr or not @entry or @cacheMap[path = @entry.filePath()]

    @cacheMap[path] = @el.innerHTML
    @cacheStack.push(path)

    while @cacheStack.length > app.config.history_cache_size
      delete @cacheMap[@cacheStack.shift()]
    return

  restore: ->
    if @cacheMap[path = @entry.filePath()]
      @render @cacheMap[path], true
      true

  onClick: (event) =>
    target = $.eventTarget(event)
    if target.hasAttribute 'data-retry'
      $.stopEvent(event)
      @load()
    else if target.classList.contains '_pre-clip'
      $.stopEvent(event)
      target.classList.add if $.copyToClipboard(target.parentNode.textContent) then '_pre-clip-success' else '_pre-clip-error'
      setTimeout (-> target.className = '_pre-clip'), 2000
    return

  onAltO: =>
    return unless link = @find('._attribution:last-child ._attribution-link')
    @delay -> $.popup(link.href + location.hash)
    return
