class app.views.Document extends app.View
  @el: document

  @shortcuts:
    help:       'onHelp'
    escape:     'onEscape'
    superLeft:  'onBack'
    superRight: 'onForward'

  init: ->
    @addSubview @nav     = new app.views.Nav,
    @addSubview @sidebar = new app.views.Sidebar
    @addSubview @content = new app.views.Content

    @setTitle()
    @activate()
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs/#{title}" else 'DevDocs'

  onHelp: ->
    app.router.show '/help#shortcuts'

  onEscape: ->
    if app.isSingleDoc() then window.location = '/' else app.router.show '/'

  onBack: ->
    history.back()

  onForward: ->
    history.forward()
