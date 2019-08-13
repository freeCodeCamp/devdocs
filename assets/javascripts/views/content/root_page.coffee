class app.views.RootPage extends app.View
  @events:
    click: 'onClick'

  init: ->
    @setHidden false unless @isHidden() # reserve space in local storage
    @render()
    return

  render: ->
    @empty()

    tmpl = if app.isAndroidWebview()
      'androidWarning'
    else if @isHidden()
      'splash'
    else if app.isMobile()
      'mobileIntro'
    else
      'intro'

    @append @tmpl(tmpl)
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
    if $.eventTarget(event).hasAttribute 'data-hide-intro'
      $.stopEvent(event)
      @hideIntro()
    return
