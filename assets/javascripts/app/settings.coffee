class app.Settings
  DOCS_KEY = 'docs'
  DARK_KEY = 'dark'
  LAYOUT_KEY = 'layout'
  SIZE_KEY = 'size'
  TIPS_KEY = 'tips'

  @defaults:
    count: 0
    hideDisabled: false
    hideIntro: false
    news: 0
    manualUpdate: false
    schema: 1

  constructor: ->
    @store = new CookieStore
    @cache = {}

  get: (key) ->
    return @cache[key] if @cache.hasOwnProperty(key)
    @cache[key] = @store.get(key) ? @constructor.defaults[key]

  set: (key, value) ->
    @store.set(key, value)
    delete @cache[key]
    return

  del: (key) ->
    @store.del(key)
    delete @cache[key]
    return

  hasDocs: ->
    try !!@store.get(DOCS_KEY)

  getDocs: ->
    @store.get(DOCS_KEY)?.split('/') or app.config.default_docs

  setDocs: (docs) ->
    @set DOCS_KEY, docs.join('/')
    return

  getTips: ->
    @store.get(TIPS_KEY)?.split('/') or []

  setTips: (tips) ->
    @set TIPS_KEY, tips.join('/')
    return

  setLayout: (name, enable) ->
    layout = (@store.get(LAYOUT_KEY) || '').split(' ')
    $.arrayDelete(layout, '')

    if enable
      layout.push(name) if layout.indexOf(name) is -1
    else
      $.arrayDelete(layout, name)

    if layout.length > 0
      @set LAYOUT_KEY, layout.join(' ')
    else
      @del LAYOUT_KEY
    return

  hasLayout: (name) ->
    layout = (@store.get(LAYOUT_KEY) || '').split(' ')
    layout.indexOf(name) isnt -1

  setSize: (value) ->
    @set SIZE_KEY, value
    return

  dump: ->
    @store.dump()

  reset: ->
    @store.reset()
    @cache = {}
    return
