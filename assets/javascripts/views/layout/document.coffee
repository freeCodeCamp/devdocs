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
    @addSubview @path    = new app.views.Path unless app.isSingleDoc() or app.isMobile()

    @setTitle()
    @activate()
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs/#{title}" else 'DevDocs'

  onHelp: ->
    app.router.show '/help#shortcuts'

  onEscape: ->
    app.router.show if app.isSingleDoc() then app.doc.fullPath() else '/'

  onBack: ->
    history.back()

  onForward: ->
    history.forward()
