class app.views.TypePage extends app.View
  @className: '_page'

  deactivate: ->
    if super
      @empty()
      @type = null
    return

  render: (@type) ->
    @html @tmpl('typePage', @type)
    return

  getTitle: ->
    "#{@type.doc.name}/#{@type.name}"

  onRoute: (context) ->
    @render context.type
    return
