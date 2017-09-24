class app.views.StaticPage extends app.View
  @className: '_static'

  @titles:
    about:    'About'
    news:     'News'
    help:     'User Guide'
    notFound: '404'

  deactivate: ->
    if super
      @empty()
      @page = null
    return

  render: (page) ->
    @page = page
    @html @tmpl("#{@page}Page")
    return

  getTitle: ->
    @constructor.titles[@page]

  onRoute: (context) ->
    @render context.page or 'notFound'
    return
