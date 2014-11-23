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
                You can also report this issue on <a href="https://github.com/Thibaut/devdocs/issues/new" target="_blank">GitHub</a>. """

app.templates.notifInvalidLocation = ->
  textNotif """ DevDocs must be loaded from #{app.config.production_host} """,
            """ Otherwise things are likely to break. """

app.templates.notifNews = (news) ->
  notif 'Changelog', app.templates.newsList(news)

app.templates.notifShare = ->
  textNotif """ Hi there! """,
            """ Like DevDocs? Help us reach more developers by sharing the link with your friends, on
                <a href="https://twitter.com/intent/tweet?url=http%3A%2F%2Fdevdocs.io&via=DevDocs&text=All-in-one%2C%20quickly%20searchable%20API%20docs%3A" target="_blank">Twitter</a>,
                <a href="https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fdevdocs.io" target="_blank">Facebook</a>,
                <a href="http://www.reddit.com/submit?url=http%3A%2F%2Fdevdocs.io&title=All-in-one%2C%20quickly%20searchable%20API%20docs&resubmit=true" target="_blank">Reddit</a>,
                etc.<br>Thanks :)"""
