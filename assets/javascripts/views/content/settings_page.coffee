class app.views.SettingsPage extends app.View
  @className: '_static'

  @events:
    click: 'onClick'
    change: 'onChange'

  render: ->
    @html @tmpl('settingsPage', @currentSettings())
    return

  currentSettings: ->
    settings = {}
    settings.theme = app.settings.get('theme')
    settings.smoothScroll = !app.settings.get('fastScroll')
    settings.arrowScroll = app.settings.get('arrowScroll')
    settings.noAutofocus = app.settings.get('noAutofocus')
    settings.autoInstall = app.settings.get('autoInstall')
    settings.analyticsConsent = app.settings.get('analyticsConsent')
    settings.spaceScroll = app.settings.get('spaceScroll')
    settings.spaceTimeout = app.settings.get('spaceTimeout')
    settings.font = app.settings.get('font')
    settings.autoSupported = app.settings.autoSupported
    settings[layout] = app.settings.hasLayout(layout) for layout in app.settings.LAYOUTS
    settings

  getTitle: ->
    'Preferences'

  setTheme: (value) ->
    app.settings.set('theme', value)
    return

  setFont: (value) ->
    app.settings.set('font', value)
    return

  toggleLayout: (layout, enable) ->
    app.settings.setLayout(layout, enable)
    return

  toggleSmoothScroll: (enable) ->
    app.settings.set('fastScroll', !enable)
    return

  toggleAnalyticsConsent: (enable) ->
    app.settings.set('analyticsConsent', if enable then '1' else '0')
    resetAnalytics() unless enable
    return

  toggleSpaceScroll: (enable) ->
    app.settings.set('spaceScroll', if enable then 1 else 0)
    return

  setScrollTimeout: (value) ->
    app.settings.set('spaceTimeout', value)

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
      when 'theme'
        @setTheme input.value
      when 'font'
        @setFont input.value
      when 'layout'
        @toggleLayout input.value, input.checked
      when 'smoothScroll'
        @toggleSmoothScroll input.checked
      when 'import'
        @import input.files[0], input
      when 'analyticsConsent'
        @toggleAnalyticsConsent input.checked
      when 'spaceScroll'
        @toggleSpaceScroll input.checked
      when 'spaceTimeout'
        @setScrollTimeout input.value
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
