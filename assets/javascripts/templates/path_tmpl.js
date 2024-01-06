arrow = """<svg class="_path-arrow"><use xlink:href="#icon-dir"/></svg>"""

app.templates.path = (doc, type, entry) ->
  html = """<a href="#{doc.fullPath()}" class="_path-item _icon-#{doc.icon}">#{doc.fullName}</a>"""
  html += """#{arrow}<a href="#{type.fullPath()}" class="_path-item">#{type.name}</a>""" if type
  html += """#{arrow}<span class="_path-item">#{$.escape entry.name}</span>""" if entry
  html
