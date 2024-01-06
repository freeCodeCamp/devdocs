class app.views.Sidebar extends app.View
  @el: '._sidebar'

  @events:
    focus: 'onFocus'
    select: 'onSelect'
    click: 'onClick'

  @routes:
    after: 'afterRoute'

  @shortcuts:
    altR: 'onAltR'
    escape: 'onEscape'

  init: ->
    @addSubview @hover  = new app.views.SidebarHover @el unless app.isMobile()
    @addSubview @search = new app.views.Search

    @search
      .on 'searching', @onSearching
      .on 'clear', @onSearchClear
    .scope
      .on 'change', @onScopeChange

    @results = new app.views.Results @, @search
    @docList = new app.views.DocList

    app.on 'ready', @onReady

    $.on document.documentElement, 'mouseleave', => @hide()
    $.on document.documentElement, 'mouseenter', => @resetDisplay(forceNoHover: false)
    return

  hide: ->
    @removeClass 'show'
    return

  display: ->
    @addClass 'show'
    return

  resetDisplay: (options = {}) ->
    return unless @hasClass 'show'
    @removeClass 'show'

    unless options.forceNoHover is false or @hasClass 'no-hover'
      @addClass 'no-hover'
      $.on window, 'mousemove', @resetHoverOnMouseMove
    return

  resetHoverOnMouseMove: =>
    $.off window, 'mousemove', @resetHoverOnMouseMove
    $.requestAnimationFrame @resetHover

  resetHover: =>
    @removeClass 'no-hover'

  showView: (view) ->
    unless @view is view
      @hover?.hide()
      @saveScrollPosition()
      @view?.deactivate()
      @view = view
      @render()
      @view.activate()
      @restoreScrollPosition()
    return

  render: ->
    @html @view
    return

  showDocList: ->
    @showView @docList
    return

  showResults: =>
    @display()
    @showView @results
    return

  reset: ->
    @display()
    @showDocList()
    @docList.reset()
    @search.reset()
    return

  onReady: =>
    @view = @docList
    @render()
    @view.activate()
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

  onSearching: =>
    @showResults()
    return

  onSearchClear: =>
    @resetDisplay()
    @showDocList()
    return

  onFocus: (event) =>
    @display()
    $.scrollTo event.target, @el, 'continuous', bottomGap: 2 unless event.target is @el
    return

  onSelect: =>
    @resetDisplay()
    return

  onClick: (event) =>
    return if event.which isnt 1
    if $.eventTarget(event).hasAttribute? 'data-reset-list'
      $.stopEvent(event)
      @onAltR()
    return

  onAltR: =>
    @reset()
    @docList.reset(revealCurrent: true)
    @display()
    return

  onEscape: =>
    @reset()
    @resetDisplay()
    if doc = @search.getScopeDoc() then @docList.reveal(doc.toEntry()) else @scrollToTop()
    return

  onDocEnabled: ->
    @docList.onEnabled()
    @reset()
    return

  afterRoute: (name, context) =>
    return if app.shortcuts.eventInProgress?.name is 'escape'
    @reset() if not context.init and app.router.isIndex()
    @resetDisplay()
    return
