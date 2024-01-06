class app.models.Type extends app.Model
  # Attributes: name, slug, count

  fullPath: ->
    "/#{@doc.slug}-#{@slug}/"

  entries: ->
    @doc.entries.findAllBy 'type', @name

  toEntry: ->
    new app.models.Entry
      doc: @doc
      name: "#{@doc.name} / #{@name}"
      path: '..' + @fullPath()
