class app.views.Path extends app.View
  @className: '_path'
  @attributes:
    role: 'complementary'

  @events:
    click: 'onClick'

  @routes:
    after: 'afterRoute'

  render: (args...) ->
    @html @tmpl 'path', args...
    @show()
    return

  show: ->
    @prependTo app.el unless @el.parentNode
    return

  hide: ->
    $.remove @el if @el.parentNode
    return

  onClick: (event) =>
    @clicked = true if link = $.closestLink event.target, @el
    return

  afterRoute: (route, context) =>
    if context.type
      @render context.doc, context.type
    else if context.entry
      if context.entry.isIndex()
        @render context.doc
      else
        @render context.doc, context.entry.getType(), context.entry
    else
      @hide()

    if @clicked
      @clicked = null
      app.document.sidebar.reset()
    return
