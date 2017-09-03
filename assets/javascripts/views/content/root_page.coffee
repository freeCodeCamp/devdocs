class app.views.RootPage extends app.View
  @events:
    click: 'onClick'

  init: ->
    @setHidden false unless @isHidden() # reserve space in local storage
    @render()
    return

  render: ->
    @empty()
    if app.isAndroidWebview()
      @append @tmpl('androidWarning')
    else
      @append @tmpl if @isHidden() then 'splash' else if app.isMobile() then 'mobileIntro' else 'intro'
    return

  hideIntro: ->
    @setHidden true
    @render()
    return

  setHidden: (value) ->
    app.settings.set 'hideIntro', value
    return

  isHidden: ->
    app.isSingleDoc() or app.settings.get 'hideIntro'

  onRoute: ->

  onClick: (event) =>
    if event.target.hasAttribute 'data-hide-intro'
      $.stopEvent(event)
      @hideIntro()
    return
