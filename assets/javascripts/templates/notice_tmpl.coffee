notice = (text) -> """<p class="_notice-text">#{_ text}</p>"""

app.templates.singleDocNotice = (doc) ->
  notice
    en: """ You're browsing the #{doc.fullName} documentation. To browse all docs, go to
            <a href="//#{app.config.production_host}" target="_top">#{app.config.production_host}</a> (or press <code>esc</code>). """
    ja: """ #{doc.fullName} をブラウズしています。すべてのドキュメントを見るには
            <a href="//#{app.config.production_host}" target="_top">#{app.config.production_host}</a> へアクセスしてください。(または<code>esc</code>を押してください) """

app.templates.disabledDocNotice = ->
  notice
    en: """ <strong>This documentation is disabled.</strong>
            To enable it, go to <a href="/settings" class="_notice-link">Preferences</a>. """
    ja: """ <strong>このドキュメントは無効です。</strong>
             有効にするには<a href="/settings" class="_notice-link">設定</a>.にアクセスしてください。"""
