class app.views.Document extends app.View
  @el: document

  @events:
    visibilitychange: 'onVisibilityChange'

  @shortcuts:
    help:       'onHelp'
    escape:     'onEscape'
    superLeft:  'onBack'
    superRight: 'onForward'

  @routes:
    after: 'afterRoute'

  init: ->
    @addSubview @menu    = new app.views.Menu,
    @addSubview @sidebar = new app.views.Sidebar
    @addSubview @resizer = new app.views.Resizer if app.views.Resizer.isSupported()
    @addSubview @content = new app.views.Content
    @addSubview @path    = new app.views.Path unless app.isSingleDoc() or app.isMobile()
    @settings = new app.views.Settings unless app.isSingleDoc()

    $.on document.body, 'click', @onClick

    @activate()
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs — #{title}" else 'DevDocs API Documentation'

  afterRoute: (route) =>
    if route is 'settings'
      @settings?.activate()
    else
      @settings?.deactivate()
    return

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

  onClick: (event) ->
    return unless event.target.hasAttribute('data-behavior')
    $.stopEvent(event)
    switch event.target.getAttribute('data-behavior')
      when 'back'         then history.back()
      when 'reload'       then window.location.reload()
      when 'reboot'       then window.location = '/'
      when 'hard-reload'  then app.reload()
      when 'reset'        then app.reset() if confirm('Are you sure you want to reset DevDocs?')
    return
