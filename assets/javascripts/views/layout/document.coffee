class app.views.Document extends app.View
  MAX_WIDTH_LAYOUT = '_max-width'
  SIDEBAR_HIDDEN_LAYOUT = '_sidebar-hidden'

  @el: document

  @events:
    visibilitychange: 'onVisibilityChange'

  @shortcuts:
    help:       'onHelp'
    escape:     'onEscape'
    superLeft:  'onBack'
    superRight: 'onForward'

  init: ->
    @addSubview @menu    = new app.views.Menu,
    @addSubview @sidebar = new app.views.Sidebar
    @addSubview @resizer = new app.views.Resizer if app.views.Resizer.isSupported()
    @addSubview @content = new app.views.Content
    @addSubview @path    = new app.views.Path unless app.isSingleDoc() or app.isMobile()

    $.on document.body, 'click', @onClick

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
    wantsMaxWidth = !app.el.classList.contains(MAX_WIDTH_LAYOUT)
    app.el.classList[if wantsMaxWidth then 'add' else 'remove'](MAX_WIDTH_LAYOUT)
    app.settings.setLayout(MAX_WIDTH_LAYOUT, wantsMaxWidth)
    app.appCache?.updateInBackground()
    return

  toggleSidebarLayout: ->
    shouldHide = !app.settings.hasLayout(SIDEBAR_HIDDEN_LAYOUT)
    app.el.classList[if shouldHide then 'add' else 'remove'](SIDEBAR_HIDDEN_LAYOUT)
    app.settings.setLayout(SIDEBAR_HIDDEN_LAYOUT, shouldHide)
    app.appCache?.updateInBackground()
    return

  setTitle: (title) ->
    @el.title = if title then "DevDocs — #{title}" else 'DevDocs API Documentation'

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
