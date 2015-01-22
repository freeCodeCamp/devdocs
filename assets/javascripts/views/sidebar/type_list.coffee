class app.views.TypeList extends app.View
  @tagName: 'div'
  @className: '_list _list-sub'

  @events:
    open:  'onOpen'
    close: 'onClose'

  constructor: (@doc) -> super

  init: ->
    @lists = {}
    @render()
    @activate()
    return

  activate: ->
    if super
      list.activate() for slug, list of @lists
    return

  deactivate: ->
    if super
      list.deactivate() for slug, list of @lists
    return

  render: ->
    html = ''
    html += @tmpl('sidebarType', group) for group in @doc.types.groups()
    @html(html)

  onOpen: (event) =>
    $.stopEvent(event)
    type = @doc.types.findBy 'slug', event.target.getAttribute('data-slug')

    if type and not @lists[type.slug]
      @lists[type.slug] = new app.views.EntryList(type.entries())
      $.after event.target, @lists[type.slug].el
    return

  onClose: (event) =>
    $.stopEvent(event)
    type = @doc.types.findBy 'slug', event.target.getAttribute('data-slug')

    if type and @lists[type.slug]
      @lists[type.slug].detach()
      delete @lists[type.slug]
    return

  paginateTo: (model) ->
    if model.type
      @lists[model.getType().slug]?.paginateTo(model)
    return
