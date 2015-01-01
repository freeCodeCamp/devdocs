app.templates.offlinePage = (docs) ->
  """ <h1 class="_lined-heading">Offline</h1>
      <table class="_docs">#{docs}</table> """

app.templates.offlineDoc = (doc, status) ->
  html = """<tr data-slug="#{doc.slug}">"""
  html += """<th class="_icon-#{doc.slug}">#{doc.name}</th>"""
  html += if status.downloaded
    """<td><a data-del>Delete</a></td>"""
  else
    """<td><a data-dl>Download</a></td>"""
  html += """</tr>"""
  html
