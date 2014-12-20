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
                <a href="/s/tw" target="_blank">Twitter</a>, <a href="/s/fb" target="_blank">Facebook</a>,
                <a href="/s/re" target="_blank">Reddit</a>, etc.<br>Thanks :) """

app.templates.notifThanks = ->
  textNotif """ Hi there! """,
            """ <p class="_notif-text">Quick shout-out to our awesome sponsors:
                <ul class="_notif-list">
                  <li><a href="http://devdocs.io/s/maxcdn" target="_blank">MaxCDN</a> has been supporting DevDocs since day one. They provide CDN solutions that make DevDocs and countless other sites faster.</li>
                  <li><a href="http://devdocs.io/s/shopify" target="_blank">Shopify</a> is where I spend my weekdays. Interested in working on one of the biggest commerce platforms in the world, in a delightful work environment? We're hiring!
                </ul>
                <p class="_notif-text">Have a great day :) """
