class app.collections.Docs extends app.Collection
  @model: 'Doc'

  sort: ->
    @models.sort (a, b) ->
      a = a.name.toLowerCase()
      b = b.name.toLowerCase()
      if a < b then -1 else if a > b then 1 else 0

  # Load models concurrently.
  # It's not pretty but I didn't want to import a promise library only for this.
  CONCURRENCY = 3
  load: (onComplete, onError, options) ->
    i = 0

    next = =>
      if i < @models.length
        @models[i].load(next, fail, options)
      else if i is @models.length + CONCURRENCY - 1
        onComplete()
      i++
      return

    fail = (args...) ->
      if onError
        onError(args...)
        onError = null
      next()
      return

    next() for [0...CONCURRENCY]
    return

  clearCache: ->
    doc.clearCache() for doc in @models
    return

  uninstall: (callback) ->
    i = 0
    next = =>
      if i < @models.length
        @models[i++].uninstall(next, next)
      else
        callback()
    next()

  getInstallStatuses: (callback) ->
    app.db.versions @models, (statuses) ->
      if statuses
        for key, value of statuses
          statuses[key] = installed: !!value, mtime: value
      callback(statuses)
