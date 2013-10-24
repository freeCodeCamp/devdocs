class app.views.RootPage extends app.View
  @events:
    click: 'onClick'

  init: ->
    @setHidden false unless @isHidden() # reserve space in local storage
    @render()
    return

  render: ->
    @empty()
    @append @tmpl('mobileNav') if app.isMobile()
    @append @tmpl if @isHidden() then 'splash' else if app.isMobile() then 'mobileIntro' else 'intro'
    return

  hideIntro: ->
    @setHidden true
    @render()
    return

  setHidden: (value) ->
    app.store.set 'hideIntro', value
    return

  isHidden: ->
    app.doc or app.store.get 'hideIntro'

  onRoute: ->

  onClick: (event) =>
    if event.target.hasAttribute 'data-hide-intro'
      $.stopEvent(event)
      @hideIntro()
    return
