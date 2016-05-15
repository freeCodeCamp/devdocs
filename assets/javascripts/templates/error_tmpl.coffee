error = (title, text = '', links = '') ->
  text = """<p class="_error-text">#{text}</p>""" if text
  links = """<p class="_error-links">#{links}</p>""" if links
  """<div class="_error"><h1 class="_error-title">#{title}</h1>#{text}#{links}</div>"""

back = '<a href="javascript:history.back()" class="_error-link">Go back</a>'

app.templates.notFoundPage = ->
  error """ Page not found. """,
        """ It may be missing from the source documentation or this could be a bug. """,
        back

app.templates.pageLoadError = ->
  error """ The page failed to load. """,
        """ It may be missing from the server (try reloading the app) or you could be offline.<br>
            If you keep seeing this, you're likely behind a proxy or firewall that blocks cross-domain requests. """,
        """ #{back} &middot; <a href="/##{location.pathname}" target="_top" class="_error-link">Reload</a>
            &middot; <a href="#" class="_error-link" data-retry>Retry</a> """

app.templates.bootError = ->
  error """ The app failed to load. """,
        """ Check your Internet connection and try <a href="javascript:location.reload()">reloading</a>.<br>
            If you keep seeing this, you're likely behind a proxy or firewall that blocks cross-domain requests. """

app.templates.offlineError = (reason) ->
  reason = switch reason
    when 'not_supported'
      """ Unfortunately your browser either doesn't support it or does not make it available. """
    when 'cant_open'
      """ Although your browser appears to support it, DevDocs couldn't open the database.<br>
          This could be because you're browsing in private mode and have disallowed offline storage on the domain. """
    when 'apple'
      """ Unfortunately Safari's implementation of IndexedDB is <a href="https://bugs.webkit.org/show_bug.cgi?id=136937">badly broken</a>.<br>
          This message will automatically go away when Apple fix their code. """

  error """ Offline mode is unavailable. """,
        """ DevDocs requires IndexedDB to cache documentations for offline access.<br>#{reason} """

app.templates.unsupportedBrowser = """
  <div class="_fail">
    <h1 class="_fail-title">Your browser is unsupported, sorry.</h1>
    <p class="_fail-text">DevDocs is an API documentation browser which supports the following browsers:
    <ul class="_fail-list">
      <li>Recent versions of Chrome and Firefox
      <li>Safari 5.1+
      <li>Opera 12.1+
      <li>Internet Explorer 10+
      <li>iOS 6+
      <li>Android 4.1+
      <li>Windows Phone 8+
    </ul>
    <p class="_fail-text">
      If you're unable to upgrade, I apologize.
      I decided to prioritize speed and new features over support for older browsers.
    <p class="_fail-text">
      Note: if you're already using one of the browsers above, check your settings and add-ons.
      The app uses feature detection, not user agent sniffing.
    <p class="_fail-text">
      &mdash; Thibaut <a href="https://twitter.com/DevDocs" class="_fail-link">@DevDocs</a>
  </div>
"""
