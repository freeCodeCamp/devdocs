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

    @results = new app.views.Results @search
    @docList = new app.views.DocList
    @docPicker = new app.views.DocPicker unless app.isSingleDoc()

    app.on 'ready', @showDocList
    $.on document, 'click', @onGlobalClick if @docPicker
    return

  show: (view) ->
    unless @view is view
      @hover?.hide()
      @saveScrollPosition()
      @view?.deactivate()
      @html @view = view
      @append @tmpl('sidebarSettings') if @view is @docList and @docPicker
      @view.activate()
      @restoreScrollPosition()
    return

  showDocList: (reset) =>
    @show @docList
    if reset is true
      @docList.reset()
      @search.reset()
    return

  showDocPicker: =>
    @show @docPicker
    return

  showResults: =>
    @show @results
    return

  reset: ->
    @showDocList true

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
    if event.target.hasAttribute? 'data-reset-list'
      $.stopEvent(event)
      @reset()
    return

  onGlobalClick: (event) =>
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
