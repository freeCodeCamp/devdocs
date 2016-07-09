class app.Router
  $.extend @prototype, Events

  @routes: [
    ['*',              'before'  ]
    ['/',              'root'    ]
    ['/offline',       'offline' ]
    ['/about',         'about'   ]
    ['/news',          'news'    ]
    ['/help',          'help'    ]
    ['/:doc-:type/',   'type'    ]
    ['/:doc/',         'doc'     ]
    ['/:doc/:path(*)', 'entry'   ]
    ['*',              'notFound']
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
    @context = context
    @trigger 'before', context
    next()
    return

  doc: (context, next) ->
    if doc = app.docs.findBySlug(context.params.doc) or app.disabledDocs.findBySlug(context.params.doc)
      context.doc = doc
      context.entry = doc.toEntry()
      @triggerRoute 'entry'
    else
      next()
    return

  type: (context, next) ->
    doc = app.docs.findBySlug(context.params.doc)

    if type = doc?.types.findBy 'slug', context.params.type
      context.doc = doc
      context.type = type
      @triggerRoute 'type'
    else
      next()
    return

  entry: (context, next) ->
    doc = app.docs.findBySlug(context.params.doc)

    if entry = doc?.findEntryByPathAndHash(context.params.path, context.hash)
      context.doc = doc
      context.entry = entry
      @triggerRoute 'entry'
    else
      next()
    return

  root: ->
    if app.isSingleDoc()
      setTimeout (-> window.location = '/'), 0
    else
      @triggerRoute 'root'
    return

  offline: ->
    @triggerRoute 'offline'
    return

  about: (context) ->
    context.page = 'about'
    @triggerRoute 'page'
    return

  news: (context) ->
    context.page = 'news'
    @triggerRoute 'page'
    return

  help: (context) ->
    context.page = 'help'
    @triggerRoute 'page'
    return

  notFound: (context) ->
    @triggerRoute 'notFound'
    return

  isRoot: ->
    location.pathname is '/'

  isDocIndex: ->
    @context.doc and @context.entry is @context.doc.toEntry()

  setInitialPath: ->
    # Remove superfluous forward slashes at the beginning of the path
    if (path = location.pathname.replace /^\/{2,}/g, '/') isnt location.pathname
      page.replace path + location.search + location.hash, null, true

    if @isRoot()
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
