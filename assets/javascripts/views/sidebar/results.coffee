class app.views.Results extends app.View
  @className: '_list'

  @routes:
    after: 'afterRoute'

  constructor: (@search) -> super

  deactivate: ->
    if super
      @empty()
    return

  init: ->
    @addSubview @listSelect = new app.views.ListSelect @el
    @addSubview @listFocus  = new app.views.ListFocus @el unless $.isTouchScreen()

    @search
      .on 'results', @onResults
      .on 'clear', @onClear
    return

  onResults: (entries, flags) =>
    @empty() if flags.initialResults
    @append @tmpl('sidebarResult', entries)

    if flags.initialResults
      if flags.urlSearch then @openFirst() else @focusFirst()
    return

  onClear: =>
    @empty()
    return

  focusFirst: ->
    @listFocus?.focus @el.firstChild
    return

  openFirst: ->
    @el.firstChild?.click()
    return

  afterRoute: (route, context) =>
    if route is 'entry'
      @listSelect.selectByHref context.entry.fullPath()
    else
      @listSelect.deselect()
    return
