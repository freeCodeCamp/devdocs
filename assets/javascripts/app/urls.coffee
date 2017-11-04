class app.Urls
  _map: {}
  _cached: {}

  get: (url) ->
    return unless url
    parsed = new URL(url)
    @_cached?[parsed.host]?[_keyFor(parsed)]

  addDoc: (doc) ->
    @_map[doc.slug] = doc.entries
      .all()
      .filter (entry) -> entry.url
      .map (entry) -> [entry.url, entry.path]
    @rebuild()

  removeDoc: (doc) ->
    deleted = delete @_map[doc.slug]
    @rebuild() if deleted
    delted

  rebuild: ->
    @_cached = {}
    for slug, entries of @_map
      for [url, path] in entries
        parsed = new URL(url)
        @_cached[parsed.host] ?= {}
        @_cached[parsed.host][_keyFor(parsed)] = "/#{slug}/#{path}"


_keyFor = (parsed) -> (parsed.pathname + parsed.search + parsed.hash).toLowerCase()
