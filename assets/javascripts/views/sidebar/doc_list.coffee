class app.views.DocList extends app.View
  @className: '_list'

  @events:
    open:  'onOpen'
    close: 'onClose'

  @routes:
    after: 'afterRoute'

  init: ->
    @lists = {}

    @addSubview @listSelect = new app.views.ListSelect @el
    @addSubview @listFocus  = new app.views.ListFocus @el unless $.isTouchScreen()
    @addSubview @listFold   = new app.views.ListFold @el

    app.on 'ready', @render
    return

  activate: ->
    if super
      list.activate() for slug, list of @lists
      @listSelect.selectCurrent()
    return

  deactivate: ->
    if super
      list.deactivate() for slug, list of @lists
    return

  render: =>
    @html @tmpl('sidebarDoc', app.docs.all())
    unless app.doc or app.settings.hasDocs()
      @append @tmpl('sidebarDoc', app.disabledDocs.all(), disabled: true)
    return

  onOpen: (event) =>
    $.stopEvent(event)
    doc = app.docs.findBy 'slug', event.target.getAttribute('data-slug')

    if doc and not @lists[doc.slug]
      @lists[doc.slug] = if doc.types.isEmpty()
        new app.views.EntryList doc.entries.all()
      else
        new app.views.TypeList doc
      $.after event.target, @lists[doc.slug].el
    return

  onClose: (event) =>
    $.stopEvent(event)
    doc = app.docs.findBy 'slug', event.target.getAttribute('data-slug')

    if doc and @lists[doc.slug]
      @lists[doc.slug].detach()
      delete @lists[doc.slug]
    return

  revealType: (type) ->
    @openDoc type.doc
    return

  revealEntry: (entry) ->
    @openDoc entry.doc
    @openType entry.getType() if entry.type
    @lists[entry.doc.slug]?.revealEntry(entry)
    return

  openDoc: (doc) ->
    @listFold.open @find("[data-slug='#{doc.slug}']")
    return

  openType: (type) ->
    @listFold.open @lists[type.doc.slug].find("[data-slug='#{type.slug}']")
    return

  afterRoute: (route, context) =>
    if context.init
      switch route
        when 'type'  then @revealType context.type
        when 'entry' then @revealEntry context.entry

    if route in ['type', 'entry']
      @listSelect.selectByHref (context.type or context.entry).fullPath()
    else
      @listSelect.deselect()

    if context.init
      $.scrollTo @listSelect.getSelection()

    return
