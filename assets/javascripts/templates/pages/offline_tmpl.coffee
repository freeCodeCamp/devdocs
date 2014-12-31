app.templates.offlinePage = ->
  """ <h1 class="_lined-heading">Offline</h1>
      <table class="_docs">
        #{app.templates.render 'offlineDoc', app.docs.all()}
      </table> """

app.templates.offlineDoc = (doc) ->
  """<tr data-slug="#{doc.slug}"></tr>"""

app.templates.offlineDocContent = (doc, status) ->
  html = """<th class="_icon-#{doc.slug}">#{doc.name}</th>"""
  html += if status.downloaded
    """<td><a data-del>Delete</a></td>"""
  else
    """<td><a data-dl>Download</a></td>"""
  html
