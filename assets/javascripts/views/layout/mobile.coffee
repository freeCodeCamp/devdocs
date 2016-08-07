class app.views.Mobile extends app.View
  @className: '_mobile'

  @elements:
    body:     'body'
    content:  '._container'
    sidebar:  '._sidebar'

  @routes:
    after: 'afterRoute'

  @detect: ->
    try
      (window.matchMedia('(max-width: 480px)').matches) or
      (window.matchMedia('(max-device-width: 767px)').matches) or
      (window.matchMedia('(max-device-height: 767px) and (max-device-width: 1024px)').matches) or
      # Need to sniff the user agent because some Android and Windows Phone devices don't take
      # resolution (dpi) into account when reporting device width/height.
      (navigator.userAgent.indexOf('Android') isnt -1 and navigator.userAgent.indexOf('Mobile') isnt -1) or
      (navigator.userAgent.indexOf('IEMobile') isnt -1)
    catch
      false

  @detectAndroidWebview: ->
    try
      /(Android).*( Version\/.\.. ).*(Chrome)/.test(navigator.userAgent)
    catch
      false

  constructor: ->
    @el = document.documentElement
    super

  init: ->
    if $.isTouchScreen()
      FastClick.attach @body
      app.shortcuts.stop()

    $.on @body, 'click', @onClick
    $.on $('._home-btn'), 'click', @onClickHome
    $.on $('._menu-btn'), 'click', @onClickMenu
    $.on $('._search'), 'touchend', @onTapSearch

    @back = $('._back-btn')
    $.on @back, 'click', @onClickBack

    @forward = $('._forward-btn')
    $.on @forward, 'click', @onClickForward

    app.document.sidebar.search
      .on 'searching', @showSidebar
      .on 'clear', @hideSidebar

    @activate()
    return

  showSidebar: =>
    if @isSidebarShown()
      @body.scrollTop = 0
      return

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

  onClickBack: =>
    history.back()

  onClickForward: =>
    history.forward()

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

    if page.canGoBack()
      @back.removeAttribute('disabled')
    else
      @back.setAttribute('disabled', 'disabled')

    if page.canGoForward()
      @forward.removeAttribute('disabled')
    else
      @forward.setAttribute('disabled', 'disabled')
    return
