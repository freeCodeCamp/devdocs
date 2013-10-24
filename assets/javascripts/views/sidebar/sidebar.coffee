class app.views.Sidebar extends app.View
  @el: '._sidebar'

  @events:
    focus: 'onFocus'

  @shortcuts:
    escape: 'onEscape'

  init: ->
    @addSubview @search = new app.views.Search

    @search
      .on('searching', @showResults)
      .on('clear', @showDocList)

    @results = new app.views.Results @search
    @docList = new app.views.DocList
    @docPicker = new app.views.DocPicker unless app.doc

    app.on 'ready', @showDocList
    $.on document, 'click', @onGlobalClick if @docPicker
    return

  show: (view) ->
    unless @view is view
      @saveScrollPosition()
      @view?.deactivate()
      @html @view = view
      @append @tmpl('sidebarSettings') if @view is @docList and @docPicker
      @view.activate()
      @restoreScrollPosition()
    return

  showDocList: =>
    @show @docList
    return

  showDocPicker: =>
    @show @docPicker
    return

  showResults: =>
    @show @results
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

  onEscape: =>
    @showDocList()
    @scrollToTop()
    return

  onGlobalClick: (event) =>
    if event.target.hasAttribute? 'data-pick-docs'
      $.stopEvent(event)
      @showDocPicker()
    else if @view is @docPicker
      @showDocList() unless $.hasChild @el, event.target
    return
