class app.Settings
  SETTINGS_KEY = 'settings'
  DOCS_KEY = 'docs'
  DARK_KEY = 'dark'
  LAYOUT_KEY = 'layout'
  SIZE_KEY = 'size'

  @defaults:
    count: 0
    hideDisabled: false
    hideIntro: false
    news: 0
    autoUpdate: true
    schema: 1

  constructor: (@store) ->
    @create() unless @settings = @store.get(SETTINGS_KEY)

  create: ->
    @settings = $.extend({}, @constructor.defaults)
    @applyLegacyValues @settings
    @save()
    return

  applyLegacyValues: (settings) ->
    for key, v of settings when (value = @store.get(key))?
      settings[key] = value
      @store.del(key)
    return

  save: ->
    @store.set SETTINGS_KEY, @settings

  set: (key, value) ->
    @settings[key] = value
    @save()

  get: (key) ->
    @settings[key] ? @constructor.defaults[key]

  hasDocs: ->
    try !!Cookies.get DOCS_KEY

  getDocs: ->
    try
      Cookies.get(DOCS_KEY)?.split('/') or app.config.default_docs
    catch
      app.config.default_docs

  setDocs: (docs) ->
    try
      Cookies.set DOCS_KEY, docs.join('/'), path: '/', expires: 1e8
    catch
    return

  setDark: (value) ->
    try
      if value
        Cookies.set DARK_KEY, '1', path: '/', expires: 1e8
      else
        Cookies.expire DARK_KEY
    catch
    return

  setLayout: (name, enable) ->
    try
      layout = (Cookies.get(LAYOUT_KEY) || '').split(' ')
      $.arrayDelete(layout, '')

      if enable
        layout.push(name) if layout.indexOf(name) is -1
      else
        $.arrayDelete(layout, name)

      if layout.length > 0
        Cookies.set LAYOUT_KEY, layout.join(' '), path: '/', expires: 1e8
      else
        Cookies.expire LAYOUT_KEY
    catch
    return

  hasLayout: (name) ->
    try
      layout = (Cookies.get(LAYOUT_KEY) || '').split(' ')
      layout.indexOf(name) isnt -1
    catch
      false

  setSize: (value) ->
    try
      Cookies.set SIZE_KEY, value, path: '/', expires: 1e8
    catch
    return

  reset: ->
    try Cookies.expire DOCS_KEY
    try Cookies.expire DARK_KEY
    try Cookies.expire LAYOUT_KEY
    try Cookies.expire SIZE_KEY
    try @store.del(SETTINGS_KEY)
    return
