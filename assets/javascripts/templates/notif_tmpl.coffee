notif = (title, html) ->
  html = html.replace /<a /g, '<a class="_notif-link" '
  """<h5 class="_notif-title">#{title}</h5>#{html}<button type="button" class="_notif-close" title="Close">Close</a>"""

textNotif = (title, message) ->
  notif title, """<p class="_notif-text">#{message}"""

app.templates.notifUpdateReady = ->
  textNotif """ DevDocs has been updated. """,
            """ <a href="#" data-behavior="reboot">Reload the page</a> to use the new version. """

app.templates.notifError = ->
  textNotif """ Oops, an error occured. """,
            """ Try <a href="#" data-behavior="hard-reload">reloading</a>, and if the problem persists,
                <a href="#" data-behavior="reset">resetting the app</a>.<br>
                You can also report this issue on <a href="https://github.com/Thibaut/devdocs/issues/new" target="_blank" rel="noopener">GitHub</a>. """

app.templates.notifQuotaExceeded = ->
  textNotif """ The offline database has exceeded its size limitation. """,
            """ Unfortunately this quota can't be detected programmatically, and the database can't be opened while over the quota, so it had to be reset. """

app.templates.notifInvalidLocation = ->
  textNotif """ DevDocs must be loaded from #{app.config.production_host} """,
            """ Otherwise things are likely to break. """

app.templates.notifNews = (news) ->
  notif 'Changelog', """<div class="_notif-content _notif-news">#{app.templates.newsList(news, years: false)}</div>"""

app.templates.notifUpdates = (docs, disabledDocs) ->
  html = '<div class="_notif-content _notif-news">'

  if docs.length > 0
    html += '<div class="_news-row">'
    html += '<ul class="_notif-list">'
    for doc in docs
      html += "<li>#{doc.name}"
      html += " <code>&rarr;</code> #{doc.release}" if doc.release
    html += '</ul></div>'

  if disabledDocs.length > 0
    html += '<div class="_news-row"><p class="_news-title">Disabled:'
    html += '<ul class="_notif-list">'
    for doc in disabledDocs
      html += "<li>#{doc.name}"
      html += " <code>&rarr;</code> #{doc.release}" if doc.release
      html += """<span class="_notif-info"><a data-pick-docs>Enable</a></span>"""
    html += '</ul></div>'

  notif 'Updates', "#{html}</div>"

app.templates.notifShare = ->
  textNotif """ Hi there! """,
            """ Like DevDocs? Help us reach more developers by sharing the link with your friends on
                <a href="http://out.devdocs.io/s/tw" target="_blank" rel="noopener">Twitter</a>, <a href="http://out.devdocs.io/s/fb" target="_blank" rel="noopener">Facebook</a>,
                <a href="http://out.devdocs.io/s/re" target="_blank" rel="noopener">Reddit</a>, etc.<br>Thanks :) """

app.templates.notifUpdateDocs = ->
  textNotif """ Documentation updates available. """,
            """ <a href="/offline">Install them</a> as soon as possible to avoid broken pages. """
