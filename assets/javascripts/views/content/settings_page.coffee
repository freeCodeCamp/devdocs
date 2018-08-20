class app.views.SettingsPage extends app.View
  LAYOUTS = ['_max-width', '_sidebar-hidden', '_native-scrollbars']
  SIDEBAR_HIDDEN_LAYOUT = '_sidebar-hidden'

  @className: '_static'

  @events:
    click: 'onClick'
    change: 'onChange'

  render: ->
    @html @tmpl('settingsPage', @currentSettings())
    return

  currentSettings: ->
    settings = {}
    settings.dark = app.settings.get('dark')
    settings.smoothScroll = !app.settings.get('fastScroll')
    settings.arrowScroll = app.settings.get('arrowScroll')
    settings[layout] = app.settings.hasLayout(layout) for layout in LAYOUTS
    settings

  getTitle: ->
    'Preferences'

  toggleDark: (enable) ->
    html = document.documentElement
    html.classList.toggle('_theme-default')
    html.classList.toggle('_theme-dark')
    app.settings.set('dark', !!enable)
    return

  toggleLayout: (layout, enable) ->
    document.body.classList[if enable then 'add' else 'remove'](layout) unless layout is SIDEBAR_HIDDEN_LAYOUT
    document.body.classList[if $.overlayScrollbarsEnabled() then 'add' else 'remove']('_overlay-scrollbars')
    app.settings.setLayout(layout, enable)
    app.appCache?.updateInBackground()
    return

  toggleSmoothScroll: (enable) ->
    app.settings.set('fastScroll', !enable)
    return

  toggle: (name, enable) ->
    app.settings.set(name, enable)
    return

  export: ->
    data = new Blob([JSON.stringify(app.settings.export())], type: 'application/json')
    link = document.createElement('a')
    link.href = URL.createObjectURL(data)
    link.download = 'devdocs.json'
    link.style.display = 'none'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    return

  import: (file, input) ->
    unless file and file.type is 'application/json'
      new app.views.Notif 'ImportInvalid', autoHide: false
      return

    reader = new FileReader()
    reader.onloadend = ->
      data = try JSON.parse(reader.result)
      unless data and data.constructor is Object
        new app.views.Notif 'ImportInvalid', autoHide: false
        return
      app.settings.import(data)
      $.trigger input.form, 'import'
      return
    reader.readAsText(file)
    return

  onChange: (event) =>
    input = event.target
    switch input.name
      when 'dark'
        @toggleDark input.checked
      when 'layout'
        @toggleLayout input.value, input.checked
      when 'smoothScroll'
        @toggleSmoothScroll input.checked
      when 'import'
        @import input.files[0], input
      else
        @toggle input.name, input.checked
    return

  onClick: (event) =>
    target = $.eventTarget(event)
    switch target.getAttribute('data-action')
      when 'export'
        $.stopEvent(event)
        @export()
    return

  onRoute: (context) ->
    @render()
    return
