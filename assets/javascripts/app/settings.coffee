class app.Settings
  PREFERENCE_KEYS = [
    'hideDisabled'
    'hideIntro'
    'manualUpdate'
    'fastScroll'
    'arrowScroll'
    'analyticsConsent'
    'docs'
    'dark' # legacy
    'theme'
    'layout'
    'size'
    'tips'
    'autoInstall'
  ]

  INTERNAL_KEYS = [
    'count'
    'schema'
    'version'
    'news'
  ]

  LAYOUTS: ['_max-width', '_sidebar-hidden', '_native-scrollbars']

  @defaults:
    count: 0
    hideDisabled: false
    hideIntro: false
    news: 0
    manualUpdate: false
    schema: 1
    analyticsConsent: false
    theme: 'auto'

  constructor: ->
    @store = new CookiesStore
    @cache = {}
    @autoSupported = window.matchMedia('(prefers-color-scheme)').media != 'not all'
    if @autoSupported
      @darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)')
      @darkModeQuery.addListener => @setTheme(@get('theme'))


  get: (key) ->
    return @cache[key] if @cache.hasOwnProperty(key)
    @cache[key] = @store.get(key) ? @constructor.defaults[key]
    if key == 'theme' and @cache[key] == 'auto' and !@darkModeQuery
      @cache[key] = 'default'
    else
      @cache[key]

  set: (key, value) ->
    @store.set(key, value)
    delete @cache[key]
    @setTheme(value) if key == 'theme'
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
    @toggleLayout(name, enable)

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

  initLayout: ->
    if @get('dark') is 1
      @set('theme', 'dark')
      @del 'dark'
    @setTheme(@get('theme'))
    @toggleLayout(layout, @hasLayout(layout)) for layout in @LAYOUTS
    @initSidebarWidth()
    return

  setTheme: (theme) ->
    if theme is 'auto'
      theme = if @darkModeQuery.matches then 'dark' else 'default'
    classList = document.documentElement.classList
    classList.remove('_theme-default', '_theme-dark')
    classList.add('_theme-' + theme)
    @updateColorMeta()
    return

  updateColorMeta: ->
    color = getComputedStyle(document.documentElement).getPropertyValue('--headerBackground').trim()
    $('meta[name=theme-color]').setAttribute('content', color)
    return

  toggleLayout: (layout, enable) ->
    classList = document.body.classList
    classList.toggle(layout, enable) unless app.router?.isSettings
    classList.toggle('_overlay-scrollbars', $.overlayScrollbarsEnabled())
    return

  initSidebarWidth: ->
    size = @get('size')
    document.documentElement.style.setProperty('--sidebarWidth', size + 'px') if size
    return
