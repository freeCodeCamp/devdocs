class app.views.SettingsPage extends app.View
  LAYOUTS = ['_max-width', '_sidebar-hidden']
  SIDEBAR_HIDDEN_LAYOUT = '_sidebar-hidden'

  @className: '_static'

  @events:
    change: 'onChange'

  render: ->
    @html @tmpl('settingsPage', @currentSettings())
    return

  currentSettings: ->
    settings = {}
    settings.dark = app.settings.getDark()
    settings[layout] = app.settings.hasLayout(layout) for layout in LAYOUTS
    settings

  getTitle: ->
    'Preferences'

  toggleDark: (enable) ->
    css = $('link[rel="stylesheet"][data-alt]')
    alt = css.getAttribute('data-alt')
    css.setAttribute('data-alt', css.getAttribute('href'))
    css.setAttribute('href', alt)
    app.settings.setDark(enable)
    app.appCache?.updateInBackground()
    return

  toggleLayout: (layout, enable) ->
    app.el.classList[if enable then 'add' else 'remove'](layout) unless layout is SIDEBAR_HIDDEN_LAYOUT
    app.settings.setLayout(layout, enable)
    app.appCache?.updateInBackground()
    return

  onChange: (event) =>
    input = event.target
    switch input.name
      when 'dark'
        @toggleDark input.checked
      when 'layout'
        @toggleLayout input.value, input.checked
    return

  onRoute: (route) =>
    if app.isSingleDoc()
      window.location = "/#/#{route.path}"
    else
      @render()
    return
