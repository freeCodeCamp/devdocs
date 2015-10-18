class app.views.EntryPage extends app.View
  @className: '_page'
  @errorClass: '_page-error'

  @events:
    click: 'onClick'

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
      @addClipboardLinks() unless fromCache
      return

    if app.disabledDocs.findBy 'slug', @entry.doc.slug
      @hiddenView = new app.views.HiddenPage @el, @entry

    @trigger 'loaded'
    return

  CLIPBOARD_LINK = '<a class="_pre-clip" title="Copy to clipboard"></a>'

  addClipboardLinks: ->
    for el in @findAllByTag('pre')
      el.insertAdjacentHTML('afterbegin', CLIPBOARD_LINK)
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
    docType = @entry.doc.type
    app.views["#{docType[0].toUpperCase()}#{docType[1..]}Page"] or app.views.BasePage

  getTitle: ->
    @entry.doc.name + if @entry.isIndex() then ' documentation' else "/#{@entry.name}"

  beforeRoute: =>
    @abort()
    @cache()
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
      @xhr = null
    return

  onSuccess: (response) =>
    return unless @activated
    @xhr = null
    @render @prepareContent(response)
    return

  onError: =>
    @xhr = null
    @render @tmpl('pageLoadError')
    @addClass @constructor.errorClass
    app.appCache?.update()
    return

  cache: ->
    return if not @entry or @cacheMap[path = @entry.filePath()]

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
    target = event.target
    if target.hasAttribute 'data-retry'
      $.stopEvent(event)
      @load()
    else if target.classList.contains '_pre-clip'
      $.stopEvent(event)
      target.classList.add if $.copyToClipboard(target.parentNode.textContent) then '_pre-clip-success' else '_pre-clip-error'
      setTimeout (-> target.className = '_pre-clip'), 2000
    return
