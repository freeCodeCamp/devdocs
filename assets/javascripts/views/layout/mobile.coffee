class app.views.Mobile extends app.View
  @className: '_mobile'

  @elements:
    body:     'body'
    content:  '._container'
    sidebar:  '._sidebar'

  @routes:
    after: 'afterRoute'

  constructor: ->
    @el = document.documentElement
    super

  init: ->
    FastClick.attach @body
    app.shortcuts.stop()

    $.on @body, 'click', @onClick
    $.on $('._home-link'), 'click', @onClickHome
    $.on $('._menu-link'), 'click', @onClickMenu
    $.on $('._search'), 'touchend', @onTapSearch

    app.document.sidebar.search
      .on 'searching', @showSidebar
      .on 'clear', @hideSidebar

    @activate()
    return

  showSidebar: =>
    return if @isSidebarShown()
    @contentTop = @body.scrollTop
    @content.style.display = 'none'
    @sidebar.style.display = 'block'

    if selection = @findByClass app.views.ListSelect.activeClass
      $.scrollTo selection, @body, 'center'
    else
      @body.scrollTop = @findByClass(app.views.ListFold.activeClass) and @sidebarTop or 0
    return

  hideSidebar: =>
    return unless @isSidebarShown()
    @sidebarTop = @body.scrollTop
    @sidebar.style.display = 'none'
    @content.style.display = 'block'
    @body.scrollTop = @contentTop or 0
    return

  isSidebarShown: ->
    @sidebar.style.display isnt 'none'

  onClick: (event) =>
    if event.target.hasAttribute 'data-pick-docs'
      @showSidebar()
    return

  onClickHome: =>
    app.shortcuts.trigger 'escape'
    @hideSidebar()
    return

  onClickMenu: =>
    if @isSidebarShown() then @hideSidebar() else @showSidebar()
    return

  onTapSearch: =>
    @body.scrollTop = 0

  afterRoute: =>
    @hideSidebar()
    return
