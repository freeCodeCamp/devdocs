class app.Router
  $.extend @prototype, Events

  @routes: [
    ['*',              'before'   ]
    ['/',              'root'     ]
    ['/settings',      'settings' ]
    ['/offline',       'offline'  ]
    ['/about',         'about'    ]
    ['/news',          'news'     ]
    ['/help',          'help'     ]
    ['/:doc-:type/',   'type'     ]
    ['/:doc/',         'doc'      ]
    ['/:doc/:path(*)', 'entry'    ]
    ['*',              'notFound' ]
  ]

  constructor: ->
    for [path, method] in @constructor.routes
      page path, @[method].bind(@)
    @setInitialPath()

  start: ->
    page.start()
    return

  show: (path) ->
    page.show(path)
    return

  triggerRoute: (name) ->
    @trigger name, @context
    @trigger 'after', name, @context
    return

  before: (context, next) ->
    previousContext = @context
    @context = context
    @trigger 'before', context

    if res = next()
      @context = previousContext
      return res
    else
      return

  doc: (context, next) ->
    if doc = app.docs.findBySlug(context.params.doc) or app.disabledDocs.findBySlug(context.params.doc)
      context.doc = doc
      context.entry = doc.toEntry()
      @triggerRoute 'entry'
      return
    else
      return next()

  type: (context, next) ->
    doc = app.docs.findBySlug(context.params.doc)

    if type = doc?.types.findBy 'slug', context.params.type
      context.doc = doc
      context.type = type
      @triggerRoute 'type'
      return
    else
      return next()

  entry: (context, next) ->
    doc = app.docs.findBySlug(context.params.doc)
    return next() unless doc
    path = context.params.path
    hash = context.hash

    if entry = doc.findEntryByPathAndHash(path, hash)
      context.doc = doc
      context.entry = entry
      @triggerRoute 'entry'
      return
    else if path.slice(-6) is '/index'
      path = path.substr(0, path.length - 6)
      return entry.fullPath() if entry = doc.findEntryByPathAndHash(path, hash)
    else
      path = "#{path}/index"
      return entry.fullPath() if entry = doc.findEntryByPathAndHash(path, hash)

    return next()

  root: ->
    return '/' if app.isSingleDoc()
    @triggerRoute 'root'
    return

  settings: (context) ->
    return "/#/#{context.path}" if app.isSingleDoc()
    @triggerRoute 'settings'
    return

  offline: (context)->
    return "/#/#{context.path}" if app.isSingleDoc()
    @triggerRoute 'offline'
    return

  about: (context) ->
    return "/#/#{context.path}" if app.isSingleDoc()
    context.page = 'about'
    @triggerRoute 'page'
    return

  news: (context) ->
    return "/#/#{context.path}" if app.isSingleDoc()
    context.page = 'news'
    @triggerRoute 'page'
    return

  help: (context) ->
    return "/#/#{context.path}" if app.isSingleDoc()
    context.page = 'help'
    @triggerRoute 'page'
    return

  notFound: (context) ->
    @triggerRoute 'notFound'
    return

  isIndex: ->
    @context?.path is '/' or (app.isSingleDoc() and @context?.entry?.isIndex())

  setInitialPath: ->
    # Remove superfluous forward slashes at the beginning of the path
    if (path = location.pathname.replace /^\/{2,}/g, '/') isnt location.pathname
      page.replace path + location.search + location.hash, null, true

    if location.pathname is '/'
      if path = @getInitialPathFromHash()
        page.replace path + location.search, null, true
      else if path = @getInitialPathFromCookie()
        page.replace path + location.search + location.hash, null, true
    return

  getInitialPathFromHash: ->
    try
      (new RegExp "#/(.+)").exec(decodeURIComponent location.hash)?[1]
    catch

  getInitialPathFromCookie: ->
    if path = Cookies.get('initial_path')
      Cookies.expire('initial_path')
      path

  replaceHash: (hash) ->
    page.replace location.pathname + location.search + (hash or ''), null, true
    return
