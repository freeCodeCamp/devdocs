class app.models.Type extends app.Model
  # Attributes: name, slug, count

  fullPath: ->
    "/#{@doc.slug}-#{@slug}/"

  entries: ->
    @doc.entries.findAllBy 'type', @name
