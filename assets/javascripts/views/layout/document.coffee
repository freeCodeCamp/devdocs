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

  toggleLight: ->
    css = $('link[rel="stylesheet"][data-alt]')
    alt = css.getAttribute('data-alt')
    css.setAttribute('data-alt', css.getAttribute('href'))
    css.setAttribute('href', alt)
    app.settings.setDark(alt.indexOf('dark') > 0)
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs/#{title}" else 'DevDocs'

  onHelp: ->
    app.router.show '/help#shortcuts'

  onEscape: ->
    path = if !app.isSingleDoc() or location.pathname is app.doc.fullPath()
      '/'
    else
      app.doc.fullPath()

    app.router.show(path)

  onBack: ->
    history.back()

  onForward: ->
    history.forward()
