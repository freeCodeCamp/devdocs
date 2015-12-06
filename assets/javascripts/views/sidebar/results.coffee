class app.views.Results extends app.View
  @className: '_list'

  @events:
    click: 'onClick'

  @routes:
    after: 'afterRoute'

  constructor: (@sidebar, @search) -> super

  deactivate: ->
    if super
      @empty()
    return

  init: ->
    @addSubview @listSelect = new app.views.ListSelect @el
    @addSubview @listFocus  = new app.views.ListFocus @el unless app.isMobile()

    @search
      .on 'results', @onResults
      .on 'noresults', @onNoResults
      .on 'clear', @onClear
    return

  onResults: (entries, flags) =>
    @listFocus?.blur() if flags.initialResults
    @empty() if flags.initialResults
    @append @tmpl('sidebarResult', entries)

    if flags.initialResults
      if flags.urlSearch then @openFirst() else @focusFirst()
    return

  onNoResults: =>
    @html @tmpl('sidebarNoResults')
    return

  onClear: =>
    @empty()
    return

  focusFirst: ->
    @listFocus?.focus @el.firstElementChild
    return

  openFirst: ->
    @el.firstElementChild?.click()
    return

  onDocEnabled: (doc) ->
    app.router.show(doc.fullPath())
    @sidebar.onDocEnabled()

  afterRoute: (route, context) =>
    if route is 'entry'
      @listSelect.selectByHref context.entry.fullPath()
    else
      @listSelect.deselect()
    return

  onClick: (event) =>
    return if event.which isnt 1
    if slug = event.target.getAttribute('data-enable')
      $.stopEvent(event)
      doc = app.disabledDocs.findBy('slug', slug)
      app.enableDoc(doc, @onDocEnabled.bind(@, doc), $.noop)
