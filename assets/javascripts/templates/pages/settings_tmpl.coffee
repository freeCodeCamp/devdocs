app.templates.settingsPage = (settings) -> """
  <h1 class="_lined-heading">Preferences</h1>

  <div class="_settings-fieldset">
    <h2 class="_settings-legend">General:</h2>

    <div class="_settings-inputs">
      <label class="_settings-label">
        <input type="checkbox" name="dark" value="1"#{if settings.dark then ' checked' else ''}>Enable dark theme
      </label>
      <label class="_settings-label _settings-max-width">
        <input type="checkbox" name="layout" value="_max-width"#{if settings['_max-width'] then ' checked' else ''}>Enable fixed-width layout
      </label>
      <label class="_settings-label">
        <input type="checkbox" name="layout" value="_sidebar-hidden"#{if settings['_sidebar-hidden'] then ' checked' else ''}>Automatically hide and show the sidebar
      </label>
    </div>
  </div>

  <div class="_settings-fieldset">
    <h2 class="_settings-legend">Advanced:</h2>

    <div class="_settings-inputs">
      <a href="#" class="_settings-link" data-behavior="reset">Reset all settings and data</a>
    </div>
  </div>
"""
