notif = (title, html) ->
  html = html.replace /<a/g, '<a class="_notif-link"'
  """<h5 class="_notif-title">#{title}</h5>#{html}<div class="_notif-close"></div>"""

textNotif = (title, message) ->
  notif title, """<p class="_notif-text">#{message}"""

app.templates.notifUpdateReady = ->
  textNotif """ DevDocs has been updated. """,
            """ <a href="javascript:location='/'">Reload the page</a> to use the new version. """

app.templates.notifError = ->
  textNotif """ Oops, an error occured. """,
            """ Try <a href="javascript:app.reload()">reloading</a>, and if the problem persists,
                <a href="javascript:app.reset()">resetting the app</a>.<br>
                I track these errors automatically but feel free to contact me. """

app.templates.notifInvalidLocation = ->
  textNotif """ DevDocs must be loaded from #{app.config.production_host} """,
            """ Otherwise things are likely to break. """

app.templates.notifNews = (news) ->
  notif 'Changelog', app.templates.newsList(news)
