app.templates.typePage = (type) ->
  """ <h1>#{type.doc.fullName} / #{type.name}</h1>
      <ul class="_entry-list">#{app.templates.render 'typePageEntry', type.entries()}</ul> """

app.templates.typePageEntry = (entry) ->
  """<li><a href="#{entry.fullPath()}">#{$.escape entry.name}</a></li>"""
