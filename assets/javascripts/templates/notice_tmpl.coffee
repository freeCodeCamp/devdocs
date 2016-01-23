notice = (text) -> """<p class="_notice-text">#{text}</p>"""

app.templates.singleDocNotice = (doc) ->
  notice """ You're currently browsing the #{doc.fullName} documentation. To browse all docs, go to
             <a href="http://#{app.config.production_host}" target="_top">#{app.config.production_host}</a> (or press <code>esc</code>). """

app.templates.disabledDocNotice = ->
  notice """ <strong>This documentation is currently disabled.</strong>
             To enable it, click <a class="_notice-link" data-pick-docs>Select documentation</a>. """
