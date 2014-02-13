class app.Router
  $.extend @prototype, Events

  @routes: [
    ['*',              'before'  ]
    ['/',              'root'    ]
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
    if doc = app.docs.findBy('slug', context.params.doc) or app.disabledDocs.findBy('slug', context.params.doc)
      context.doc = doc
      context.entry = doc.toEntry()
      @triggerRoute 'entry'
    else
      next()
    return

  type: (context, next) ->
    doc = app.docs.findBy 'slug', context.params.doc

    if type = doc?.types.findBy 'slug', context.params.type
      context.doc = doc
      context.type = type
      @triggerRoute 'type'
    else
      next()
    return

  entry: (context, next) ->
    doc = app.docs.findBy 'slug', context.params.doc

    if entry = doc?.findEntryByPathAndHash(context.params.path, context.hash)
      context.doc = doc
      context.entry = entry
      @triggerRoute 'entry'
    else
      next()
    return

  root: ->
    @triggerRoute 'root'
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

  setInitialPath: ->
    # Remove superfluous forward slashes at the beginning of the path
    if (path = location.pathname.replace /^\/{2,}/g, '/') isnt location.pathname
      page.replace path + location.search + location.hash, null, true

    # When the path is "/#/path", replace it with "/path"
    if @isRoot() and path = @getInitialPath()
      page.replace path + location.search, null, true
    return

  getInitialPath: ->
    try
      (new RegExp "#/(.+)").exec(decodeURIComponent location.hash)?[1]
    catch

  replaceHash: (hash) ->
    page.replace location.pathname + location.search + (hash or ''), null, true
    return
