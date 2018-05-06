notif = (title, html) ->
  close = _ en: 'Close', ja: '閉じる'
  html = html.replace /<a /g, '<a class="_notif-link" '
  """ <h5 class="_notif-title">#{_ title}</h5>
      #{html}
      <button type="button" class="_notif-close" title="#{close}"><svg><use xlink:href="#icon-close"/></svg>#{close}</a>
  """

textNotif = (title, message) ->
  notif title, """<p class="_notif-text">#{_ message}"""

app.templates.notifUpdateReady = ->
  textNotif
    en: """<span data-behavior="reboot">DevDocs has been updated.</span>"""
    ja: """<span data-behavior="reboot">DevDocsはアップデートされました。</span>"""
  ,
    en: """<span data-behavior="reboot"><a href="#" data-behavior="reboot">Reload the page</a> to use the new version.</span>"""
    ja: """<span data-behavior="reboot"><a href="#" data-behavior="reboot">ページ再読み込み</a> すると新しいバージョンが使用できます。</span>"""

app.templates.notifError = ->
  textNotif
    en: """ Oops, an error occurred. """
    ja: """ しまった、エラーが発生しました。 """
  ,
    en: """ Try <a href="#" data-behavior="hard-reload">reloading</a>, and if the problem persists,
            <a href="#" data-behavior="reset">resetting the app</a>.<br>
            You can also report this issue on <a href="https://github.com/freeCodeCamp/devdocs/issues/new" target="_blank" rel="noopener">GitHub</a>. """
    ja: """ <a href="#" data-behavior="hard-reload">再読み込み</a>してみてください。それでも問題が起きる場合は、
            <a href="#" data-behavior="reset">アプリをリセット</a>してください。<br>
            この問題を<a href="https://github.com/freeCodeCamp/devdocs/issues/new" target="_blank" rel="noopener">GitHub</a>で報告することができます。 """


app.templates.notifQuotaExceeded = ->
  textNotif
    en: """ The offline database has exceeded its size limitation. """
    ja: """ オフラインデータベースはサイズ制限を超過しました。 """
  ,
    en: """ Unfortunately this quota can't be detected programmatically, and the database can't be opened while over the quota, so it had to be reset. """
    ja: """ あいにく、この制限を検出するようプログラムできません。また、データベースは制限を超えて開くことができません。そのため、リセットを行ってください。"""

app.templates.notifCookieBlocked = ->
  textNotif
    en: """ Please enable cookies. """
    ja: """ クッキーを有効にしてください。"""
  ,
    en: """ DevDocs will not work properly if cookies are disabled. """
    ja: """ クッキーが無効な場合、DevDocsは正確に動きません。"""

app.templates.notifInvalidLocation = ->
  textNotif
    en: """ DevDocs must be loaded from #{app.config.production_host} """
    ja: """ DevDocsは#{app.config.production_host}から読み込む必要があります。 """
  ,
    en: """ Otherwise things are likely to break. """
    ja: """ さもないと故障してしまうかもしれません。"""

app.templates.notifImportInvalid = ->
  textNotif
    en: """ Oops, an error occurred. """
    ja: """ しまった、エラーが発生しました。"""
  ,
    en: """ The file you selected is invalid. """
    ja: """ 選択したファイルは無効です。 """

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
      html += """<span class="_notif-info"><a href="/settings">#{__ 'enable'}</a></span>"""
    html += '</ul></div>'

  notif 'Updates', "#{html}</div>"

app.templates.notifShare = ->
  textNotif
    en: """ Hi there! """
    ja: """ ようこそ！ """
  ,
    en: """ Like DevDocs? Help us reach more developers by sharing the link with your friends on
            <a href="https://out.devdocs.io/s/tw" target="_blank" rel="noopener">Twitter</a>, <a href="https://out.devdocs.io/s/fb" target="_blank" rel="noopener">Facebook</a>,
            <a href="https://out.devdocs.io/s/re" target="_blank" rel="noopener">Reddit</a>, etc.<br>Thanks :) """
    ja: """ DevDocsは気に入りましたか? さらに開発者に知ってもらえるよう、友人などにシェアしていただけませんか。
            <a href="https://out.devdocs.io/s/tw" target="_blank" rel="noopener">Twitter</a>, <a href="https://out.devdocs.io/s/fb" target="_blank" rel="noopener">Facebook</a>,
            <a href="https://out.devdocs.io/s/re" target="_blank" rel="noopener">Reddit</a>などで。<br>よろしく:) """

app.templates.notifUpdateDocs = ->
  textNotif
    en: """ Documentation updates available. """
    ja: """ ドキュメントのアップデートが入手可能です。 """
  ,
    en: """ <a href="/offline">Install them</a> as soon as possible to avoid broken pages. """
    ja: """ <a href="/offline">インストールする</a> とすぐに可能になり、壊れたページを回避できます。 """
