app.templates.path = (doc, type, entry) ->
  html = """<a href="#{doc.fullPath()}" class="_path-item _icon-#{doc.slug}">#{doc.name}</a>"""
  html += """<a href="#{type.fullPath()}" class="_path-item">#{type.name}</a>""" if type
  html += """<span class="_path-item">#{$.escape entry.name}</span>""" if entry
  html
