class app.views.Document extends app.View
  MAX_WIDTH_CLASS = '_max-width'
  HIDE_SIDEBAR_CLASS = '_sidebar-hidden'

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

    @sidebar.search
      .on 'searching', @onSearching
      .on 'clear', @onSearchClear

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

  toggleColor: (theme) ->
    # TODO
    switch theme
      when "dark" then newcss="/assets/application-dark.css"
      when "sepia" then newcss="/assets/application-sepia.css"
      when "default" then newcss="/assets/application.css"        
      else newcss="/assets/application.css"        
    css = $('link[rel="stylesheet"][data-alt]')
    css.setAttribute('href', newcss)  
    app.settings.setDark(newcss.indexOf('dark') > 0)
    app.settings.setSepia(newcss.indexOf('sepia') > 0)          
    app.appCache?.updateInBackground()
    return  

  toggleLayout: ->
    wantsMaxWidth = !app.el.classList.contains(MAX_WIDTH_CLASS)
    app.el.classList[if wantsMaxWidth then 'add' else 'remove'](MAX_WIDTH_CLASS)
    app.settings.setLayout(MAX_WIDTH_CLASS, wantsMaxWidth)
    app.appCache?.updateInBackground()
    return

  showSidebar: (options = {}) ->
    @toggleSidebar(options, true)
    return

  hideSidebar: (options = {}) ->
    @toggleSidebar(options, false)
    return

  toggleSidebar: (options = {}, shouldShow) ->
    shouldShow ?= if options.save then !@hasSidebar() else app.el.classList.contains(HIDE_SIDEBAR_CLASS)
    app.el.classList[if shouldShow then 'remove' else 'add'](HIDE_SIDEBAR_CLASS)
    if options.save
      app.settings.setLayout(HIDE_SIDEBAR_CLASS, !shouldShow)
      app.appCache?.updateInBackground()
    return

  hasSidebar: ->
    !app.settings.hasLayout(HIDE_SIDEBAR_CLASS)

  onSearching: =>
    unless @hasSidebar()
      @showSidebar()
    return

  onSearchClear: =>
    unless @hasSidebar()
      @hideSidebar()
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
