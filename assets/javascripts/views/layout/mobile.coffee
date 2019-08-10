class app.views.Mobile extends app.View
  @className: '_mobile'

  @elements:
    body:      'body'
    content:   '._container'
    sidebar:   '._sidebar'
    docPicker: '._settings ._sidebar'

  @shortcuts:
    escape: 'onEscape'

  @routes:
    after: 'afterRoute'

  @detect: ->
    try
      (window.matchMedia('(max-width: 480px)').matches) or
      (window.matchMedia('(max-width: 767px)').matches) or
      (window.matchMedia('(max-height: 767px) and (max-width: 1024px)').matches) or
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
    window.FastClick?.attach @body

    $.on $('._search'), 'touchend', @onTapSearch

    @toggleSidebar = $('button[data-toggle-sidebar]')
    @toggleSidebar.removeAttribute('hidden')
    $.on @toggleSidebar, 'click', @onClickToggleSidebar

    @back = $('button[data-back]')
    @back.removeAttribute('hidden')
    $.on @back, 'click', @onClickBack

    @forward = $('button[data-forward]')
    @forward.removeAttribute('hidden')
    $.on @forward, 'click', @onClickForward

    @docPickerTab = $('button[data-tab="doc-picker"]')
    @docPickerTab.removeAttribute('hidden')
    $.on @docPickerTab, 'click', @onClickDocPickerTab

    @settingsTab = $('button[data-tab="settings"]')
    @settingsTab.removeAttribute('hidden')
    $.on @settingsTab, 'click', @onClickSettingsTab

    app.document.sidebar.search
      .on 'searching', @showSidebar

    @activate()
    return

  showSidebar: =>
    if @isSidebarShown()
      window.scrollTo 0, 0
      return

    @contentTop = window.scrollY
    @content.style.display = 'none'
    @sidebar.style.display = 'block'

    if selection = @findByClass app.views.ListSelect.activeClass
      scrollContainer = if window.scrollY is @body.scrollTop then @body else document.documentElement
      $.scrollTo selection, scrollContainer, 'center'
    else
      window.scrollTo 0, @findByClass(app.views.ListFold.activeClass) and @sidebarTop or 0
    return

  hideSidebar: =>
    return unless @isSidebarShown()
    @sidebarTop = window.scrollY
    @sidebar.style.display = 'none'
    @content.style.display = 'block'
    window.scrollTo 0, @contentTop or 0
    return

  isSidebarShown: ->
    @sidebar.style.display isnt 'none'

  onClickBack: =>
    history.back()

  onClickForward: =>
    history.forward()

  onClickToggleSidebar: =>
    if @isSidebarShown() then @hideSidebar() else @showSidebar()
    return

  onClickDocPickerTab: (event) =>
    $.stopEvent(event)
    @showDocPicker()
    return

  onClickSettingsTab: (event) =>
    $.stopEvent(event)
    @showSettings()
    return

  showDocPicker: ->
    window.scrollTo 0, 0
    @docPickerTab.classList.add 'active'
    @settingsTab.classList.remove 'active'
    @docPicker.style.display = 'block'
    @content.style.display = 'none'
    return

  showSettings: ->
    window.scrollTo 0, 0
    @docPickerTab.classList.remove 'active'
    @settingsTab.classList.add 'active'
    @docPicker.style.display = 'none'
    @content.style.display = 'block'
    return

  onTapSearch: =>
    window.scrollTo 0, 0

  onEscape: =>
    @hideSidebar()

  afterRoute: (route) =>
    @hideSidebar()

    if route is 'settings'
      @showDocPicker()
    else
      @content.style.display = 'block'

    if page.canGoBack()
      @back.removeAttribute('disabled')
    else
      @back.setAttribute('disabled', 'disabled')

    if page.canGoForward()
      @forward.removeAttribute('disabled')
    else
      @forward.setAttribute('disabled', 'disabled')
    return
