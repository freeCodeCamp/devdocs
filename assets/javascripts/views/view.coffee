class app.View
  $.extend @prototype, Events

  constructor: ->
    @setupElement()
    @originalClassName = @el.className if @el.className
    @resetClass() if @constructor.className
    @refreshElements()
    @init?()
    @refreshElements()

  setupElement: ->
    @el ?= if typeof @constructor.el is 'string'
      $ @constructor.el
    else if @constructor.el
      @constructor.el
    else
      document.createElement @constructor.tagName or 'div'

    if @constructor.attributes
      for key, value of @constructor.attributes
        @el.setAttribute(key, value)
    return

  refreshElements: ->
    if @constructor.elements
      @[name] = @find selector for name, selector of @constructor.elements
    return

  addClass: (name) ->
    @el.classList.add(name)
    return

  removeClass: (name) ->
    @el.classList.remove(name)
    return

  toggleClass: (name) ->
    @el.classList.toggle(name)
    return

  hasClass: (name) ->
    @el.classList.contains(name)

  resetClass: ->
    @el.className = @originalClassName or ''
    if @constructor.className
      @addClass name for name in @constructor.className.split ' '
    return

  find: (selector) ->
    $ selector, @el

  findAll: (selector) ->
    $$ selector, @el

  findByClass: (name) ->
    @findAllByClass(name)[0]

  findLastByClass: (name) ->
    all = @findAllByClass(name)[0]
    all[all.length - 1]

  findAllByClass: (name) ->
    @el.getElementsByClassName(name)

  findByTag: (tag) ->
    @findAllByTag(tag)[0]

  findLastByTag: (tag) ->
    all = @findAllByTag(tag)
    all[all.length - 1]

  findAllByTag: (tag) ->
    @el.getElementsByTagName(tag)

  append: (value) ->
    $.append @el, value.el or value
    return

  appendTo: (value) ->
    $.append value.el or value, @el
    return

  prepend: (value) ->
    $.prepend @el, value.el or value
    return

  prependTo: (value) ->
    $.prepend value.el or value, @el
    return

  before: (value) ->
    $.before @el, value.el or value
    return

  after: (value) ->
    $.after @el, value.el or value
    return

  remove: (value) ->
    $.remove value.el or value
    return

  empty: ->
    $.empty @el
    @refreshElements()
    return

  html: (value) ->
    @empty()
    @append value
    return

  tmpl: (args...) ->
    app.templates.render(args...)

  delay: (fn, args...) ->
    delay = if typeof args[args.length - 1] is 'number' then args.pop() else 0
    setTimeout fn.bind(@, args...), delay

  onDOM: (event, callback) ->
    $.on @el, event, callback
    return

  offDOM: (event, callback) ->
    $.off @el, event, callback
    return

  bindEvents: ->
    if @constructor.events
      @onDOM name, @[method] for name, method of @constructor.events

    if @constructor.routes
      app.router.on name, @[method] for name, method of @constructor.routes

    if @constructor.shortcuts
      app.shortcuts.on name, @[method] for name, method of @constructor.shortcuts
    return

  unbindEvents: ->
    if @constructor.events
      @offDOM name, @[method] for name, method of @constructor.events

    if @constructor.routes
      app.router.off name, @[method] for name, method of @constructor.routes

    if @constructor.shortcuts
      app.shortcuts.off name, @[method] for name, method of @constructor.shortcuts
    return

  addSubview: (view) ->
    (@subviews or= []).push(view)

  activate: ->
    return if @activated
    @bindEvents()
    view.activate() for view in @subviews if @subviews
    @activated = true
    true

  deactivate: ->
    return unless @activated
    @unbindEvents()
    view.deactivate() for view in @subviews if @subviews
    @activated = false
    true

  detach: ->
    @deactivate()
    $.remove @el
    return
