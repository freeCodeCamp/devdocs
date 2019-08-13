class app.views.TypePage extends app.View
  @className: '_page'

  deactivate: ->
    if super
      @empty()
      @type = null
    return

  render: (@type) ->
    @html @tmpl('typePage', @type)
    setFaviconForDoc(@type.doc)
    return

  getTitle: ->
    "#{@type.doc.fullName} / #{@type.name}"

  onRoute: (context) ->
    @render context.type
    return
