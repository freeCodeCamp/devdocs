class app.views.Document extends app.View
  MAX_WIDTH_CLASS = '_max-width'

  @el: document

  @events:
    visibilitychange: 'onVisibilityChange'

  @shortcuts:
    help:       'onHelp'
    escape:     'onEscape'
    superLeft:  'onBack'
    superRight: 'onForward'

  init: ->
    @addSubview @nav     = new app.views.Nav,
    @addSubview @sidebar = new app.views.Sidebar
    @addSubview @resizer = new app.views.Resizer if app.views.Resizer.isSupported()
    @addSubview @content = new app.views.Content
    @addSubview @path    = new app.views.Path unless app.isSingleDoc() or app.isMobile()

    @activate()
    return

  toggleLight: ->
    css = $('link[rel="stylesheet"][data-alt]')
    alt = css.getAttribute('data-alt')
    css.setAttribute('data-alt', css.getAttribute('href'))
    css.setAttribute('href', alt)
    app.settings.setDark(alt.indexOf('dark') > 0)
    app.appCache?.updateInBackground()
    return

  toggleLayout: ->
    wantsMaxWidth = !app.el.classList.contains(MAX_WIDTH_CLASS)
    app.el.classList[if wantsMaxWidth then 'add' else 'remove'](MAX_WIDTH_CLASS)
    app.settings.setLayout(if wantsMaxWidth then MAX_WIDTH_CLASS else false)
    app.appCache?.updateInBackground()
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs - #{title}" else 'DevDocs API Documentation'

  onVisibilityChange: =>
    return unless @el.visibilityState is 'visible'
    @delay ->
      location.reload() if app.isMobile() isnt app.views.Mobile.detect()
      return
    , 300
    return

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
