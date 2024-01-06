class app.views.DocList extends app.View
  @className: '_list'
  @attributes:
    role: 'navigation'

  @events:
    open:  'onOpen'
    close: 'onClose'
    click: 'onClick'

  @routes:
    after: 'afterRoute'

  @elements:
    disabledTitle: '._list-title'
    disabledList: '._disabled-list'

  init: ->
    @lists = {}

    @addSubview @listFocus  = new app.views.ListFocus @el
    @addSubview @listFold   = new app.views.ListFold @el
    @addSubview @listSelect = new app.views.ListSelect @el

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
    html = ''
    for doc in app.docs.all()
      html += @tmpl('sidebarDoc', doc, fullName: app.docs.countAllBy('name', doc.name) > 1)
    @html html
    @renderDisabled() unless app.isSingleDoc() or app.disabledDocs.size() is 0
    return

  renderDisabled: ->
    @append @tmpl('sidebarDisabled', count: app.disabledDocs.size())
    @refreshElements()
    @renderDisabledList()
    return

  renderDisabledList: ->
    if app.settings.get('hideDisabled')
      @removeDisabledList()
    else
      @appendDisabledList()
    return

  appendDisabledList: ->
    html = ''
    docs = [].concat(app.disabledDocs.all()...)

    while doc = docs.shift()
      if doc.version?
        versions = ''
        loop
          versions += @tmpl('sidebarDoc', doc, disabled: true)
          break if docs[0]?.name isnt doc.name
          doc = docs.shift()
        html += @tmpl('sidebarDisabledVersionedDoc', doc, versions)
      else
        html += @tmpl('sidebarDoc', doc, disabled: true)

    @append @tmpl('sidebarDisabledList', html)
    @disabledTitle.classList.add('open-title')
    @refreshElements()
    return

  removeDisabledList: ->
    $.remove @disabledList if @disabledList
    @disabledTitle.classList.remove('open-title')
    @refreshElements()
    return

  reset: (options = {}) ->
    @listSelect.deselect()
    @listFocus?.blur()
    @listFold.reset()
    @revealCurrent() if options.revealCurrent || app.isSingleDoc()
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

  select: (model) ->
    @listSelect.selectByHref model?.fullPath()
    return

  reveal: (model) ->
    @openDoc model.doc
    @openType model.getType() if model.type
    @focus model
    @paginateTo model
    @scrollTo model
    return

  focus: (model) ->
    @listFocus?.focus @find("a[href='#{model.fullPath()}']")
    return

  revealCurrent: ->
    if model = app.router.context.type or app.router.context.entry
      @reveal model
      @select model
    return

  openDoc: (doc) ->
    @listFold.open @find("[data-slug='#{doc.slug_without_version}']") if app.disabledDocs.contains(doc) and doc.version
    @listFold.open @find("[data-slug='#{doc.slug}']")
    return

  closeDoc: (doc) ->
    @listFold.close @find("[data-slug='#{doc.slug}']")
    return

  openType: (type) ->
    @listFold.open @lists[type.doc.slug].find("[data-slug='#{type.slug}']")
    return

  paginateTo: (model) ->
    @lists[model.doc.slug]?.paginateTo(model)
    return

  scrollTo: (model) ->
    $.scrollTo @find("a[href='#{model.fullPath()}']"), null, 'top', margin: if app.isMobile() then 48 else 0
    return

  toggleDisabled: ->
    if @disabledTitle.classList.contains('open-title')
      @removeDisabledList()
      app.settings.set 'hideDisabled', true
    else
      @appendDisabledList()
      app.settings.set 'hideDisabled', false
    return

  onClick: (event) =>
    target = $.eventTarget(event)
    if @disabledTitle and $.hasChild(@disabledTitle, target) and target.tagName isnt 'A'
      $.stopEvent(event)
      @toggleDisabled()
    else if slug = target.getAttribute('data-enable')
      $.stopEvent(event)
      doc = app.disabledDocs.findBy('slug', slug)
      app.enableDoc(doc, @onEnabled, @onEnabled) if doc
    return

  onEnabled: =>
    @reset()
    @render()
    return

  afterRoute: (route, context) =>
    if context.init
      @reset revealCurrent: true if @activated
    else
      @select context.type or context.entry
    return
