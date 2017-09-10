class app.Settings
  PREFERENCE_KEYS = [
    'hideDisabled'
    'hideIntro'
    'manualUpdate'
    'fastScroll'
    'arrowScroll'
    'docs'
    'dark'
    'layout'
    'size'
    'tips'
  ]

  INTERNAL_KEYS = [
    'count'
    'schema'
    'version'
    'news'
  ]

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
    try !!@store.get('docs')

  getDocs: ->
    @store.get('docs')?.split('/') or app.config.default_docs

  setDocs: (docs) ->
    @set 'docs', docs.join('/')
    return

  getTips: ->
    @store.get('tips')?.split('/') or []

  setTips: (tips) ->
    @set 'tips', tips.join('/')
    return

  setLayout: (name, enable) ->
    layout = (@store.get('layout') || '').split(' ')
    $.arrayDelete(layout, '')

    if enable
      layout.push(name) if layout.indexOf(name) is -1
    else
      $.arrayDelete(layout, name)

    if layout.length > 0
      @set 'layout', layout.join(' ')
    else
      @del 'layout'
    return

  hasLayout: (name) ->
    layout = (@store.get('layout') || '').split(' ')
    layout.indexOf(name) isnt -1

  setSize: (value) ->
    @set 'size', value
    return

  dump: ->
    @store.dump()

  export: ->
    data = @dump()
    delete data[key] for key in INTERNAL_KEYS
    data

  import: (data) ->
    for key, value of @export()
      @del key unless data.hasOwnProperty(key)
    for key, value of data
      @set key, value if PREFERENCE_KEYS.indexOf(key) isnt -1
    return

  reset: ->
    @store.reset()
    @cache = {}
    return
