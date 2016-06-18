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

  constructor: (legacyStore) ->
    @store = new CookieStore
    @importLegacyValues(legacyStore)

  importLegacyValues: (legacyStore) ->
    return unless settings = legacyStore.get('settings')
    for key, value of settings
      if key == 'autoUpdate'
        key = 'manualUpdate'
        value = !value
      else if key == 'tips'
        value = value.join('/')
      @store.set(key, value)
    legacyStore.del('settings')
    return

  set: (key, value) ->
    @store.set(key, value)
    return

  get: (key) ->
    @store.get(key) ? @constructor.defaults[key]

  hasDocs: ->
    try !!@store.get(DOCS_KEY)

  getDocs: ->
    @store.get(DOCS_KEY)?.split('/') or app.config.default_docs

  setDocs: (docs) ->
    @store.set DOCS_KEY, docs.join('/')
    return

  getTips: ->
    @store.get(TIPS_KEY)?.split('/') or []

  setTips: (tips) ->
    @store.set TIPS_KEY, tips.join('/')
    return

  setDark: (value) ->
    @store.set DARK_KEY, !!value
    return

  setLayout: (name, enable) ->
    layout = (@store.get(LAYOUT_KEY) || '').split(' ')
    $.arrayDelete(layout, '')

    if enable
      layout.push(name) if layout.indexOf(name) is -1
    else
      $.arrayDelete(layout, name)

    if layout.length > 0
      @store.set LAYOUT_KEY, layout.join(' ')
    else
      @store.del LAYOUT_KEY
    return

  hasLayout: (name) ->
    layout = (@store.get(LAYOUT_KEY) || '').split(' ')
    layout.indexOf(name) isnt -1

  setSize: (value) ->
    @store.set SIZE_KEY, value
    return

  dump: ->
    @store.dump()

  reset: ->
    @store.reset()
    return
