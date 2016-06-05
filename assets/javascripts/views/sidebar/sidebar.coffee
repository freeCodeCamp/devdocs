class app.views.Sidebar extends app.View
  @el: '._sidebar'

  @events:
    focus: 'onFocus'
    click: 'onClick'

  @shortcuts:
    altR: 'onAltR'
    escape: 'onEscape'

  init: ->
    @addSubview @hover  = new app.views.SidebarHover @el unless app.isMobile() or $.isTouchScreen()
    @addSubview @search = new app.views.Search

    @search
      .on 'searching', @showResults
      .on 'clear', @showDocList
    .scope
      .on 'change', @onScopeChange

    @results = new app.views.Results @, @search
    @docList = new app.views.DocList
    @docPicker = new app.views.DocPicker unless app.isSingleDoc()

    app.on 'ready', @onReady
    $.on document, 'click', @onGlobalClick if @docPicker
    return

  show: (view) ->
    unless @view is view
      @hover?.hide()
      @saveScrollPosition()
      @view?.deactivate()
      @view = view
      @render()
      @view.activate()
      @restoreScrollPosition()
      if view is @docPicker then @search.disable() else @search.enable()
    return

  render: ->
    @html @view
    @append @tmpl('sidebarSettings') if @view is @docList and @docPicker
    return

  showDocList: (reset) =>
    @show @docList
    if reset is true
      @docList.reset(revealCurrent: true)
      @search.reset()
    return

  showDocPicker: =>
    @show @docPicker
    return

  showResults: =>
    @show @results
    return

  onReady: =>
    @view = @docList
    @render()
    @view.activate()

  reset: ->
    @showDocList true
    return

  onScopeChange: (newDoc, previousDoc) =>
    @docList.closeDoc(previousDoc) if previousDoc
    if newDoc then @docList.reveal(newDoc.toEntry()) else @scrollToTop()
    return

  saveScrollPosition: ->
    if @view is @docList
      @scrollTop = @el.scrollTop
    return

  restoreScrollPosition: ->
    if @view is @docList and @scrollTop
      @el.scrollTop = @scrollTop
      @scrollTop = null
    else
      @scrollToTop()
    return

  scrollToTop: ->
    @el.scrollTop = 0
    return

  onFocus: (event) =>
    $.scrollTo event.target, @el, 'continuous', bottomGap: 2
    return

  onClick: (event) =>
    return if event.which isnt 1
    if event.target.hasAttribute? 'data-reset-list'
      $.stopEvent(event)
      @reset()
    else if event.target.hasAttribute? 'data-light'
      $.stopEvent(event)
      app.document.toggleLight()
    else if event.target.hasAttribute? 'data-layout'
      $.stopEvent(event)
      app.document.toggleLayout()
    return

  onGlobalClick: (event) =>
    return if event.which isnt 1
    if event.target.hasAttribute? 'data-pick-docs'
      $.stopEvent(event)
      @showDocPicker()
    else if @view is @docPicker
      @showDocList() unless $.hasChild @el, event.target
    return

  onAltR: =>
    @reset()
    return

  onEscape: =>
    @reset()
    @scrollToTop()
    return

  onDocEnabled: ->
    @docList.onEnabled()
    @reset()
