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
                <a href="javascript:if(confirm('Are you sure you want to reset DevDocs?'))app.reset()">resetting the app</a>.<br>
                You can also report this issue on <a href="https://github.com/Thibaut/devdocs/issues/new" target="_blank">GitHub</a>. """

app.templates.notifQuotaExceeded = ->
  textNotif """ Oops, the offline database has exceeded its size limitation. """,
            """ Unfortunately this quota can't be detected programmatically, and the database can't be opened while over the quota, so it had to be reset. """

app.templates.notifInvalidLocation = ->
  textNotif """ DevDocs must be loaded from #{app.config.production_host} """,
            """ Otherwise things are likely to break. """

app.templates.notifNews = (news) ->
  notif 'Changelog', app.templates.newsList(news)

app.templates.notifShare = ->
  textNotif """ Hi there! """,
            """ Like DevDocs? Help us reach more developers by sharing the link with your friends, on
                <a href="http://out.devdocs.io/s/tw" target="_blank">Twitter</a>, <a href="http://out.devdocs.io/s/fb" target="_blank">Facebook</a>,
                <a href="http://out.devdocs.io/s/re" target="_blank">Reddit</a>, etc.<br>Thanks :) """

app.templates.notifThanks = ->
  textNotif """ Hi there! """,
            """ <p class="_notif-text">Like DevDocs? Check out these awesome companies who are making it possible:
                <ul class="_notif-list">
                  <li><a href="http://out.devdocs.io/s/code-school" target="_blank">Code School</a> — Learn new skills from the comfort of your own browser. Offering more than 45 courses covering JavaScript, HTML/CSS, Ruby, Git, and iOS for only $29/month.
                </ul>
                <p class="_notif-text">Have a great day :) """

app.templates.notifUpdateDocs = ->
  textNotif """ Documentation updates available. """,
            """ <a href="/offline">Install them</a> as soon as possible to avoid broken pages. """
