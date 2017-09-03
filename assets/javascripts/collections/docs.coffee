class app.collections.Docs extends app.Collection
  @model: 'Doc'

  findBySlug: (slug) ->
    @findBy('slug', slug) or @findBy('slug_without_version', slug)

  NORMALIZE_VERSION_RGX = /\.(\d)$/
  NORMALIZE_VERSION_SUB = '.0$1'
  sort: ->
    @models.sort (a, b) ->
      if a.name is b.name
        if not a.version or a.version.replace(NORMALIZE_VERSION_RGX, NORMALIZE_VERSION_SUB) > b.version.replace(NORMALIZE_VERSION_RGX, NORMALIZE_VERSION_SUB)
          -1
        else
          1
      else if a.name.toLowerCase() > b.name.toLowerCase()
        1
      else
        -1

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
      return
    next()
    return

  getInstallStatuses: (callback) ->
    app.db.versions @models, (statuses) ->
      if statuses
        for key, value of statuses
          statuses[key] = installed: !!value, mtime: value
      callback(statuses)
      return
    return

  checkForUpdates: (callback) ->
    @getInstallStatuses (statuses) =>
      i = 0
      if statuses
        i += 1 for slug, status of statuses when @findBy('slug', slug).isOutdated(status)
      callback(i)
      return
    return

  updateInBackground: ->
    @getInstallStatuses (statuses) =>
      return unless statuses
      for slug, status of statuses
        doc = @findBy 'slug', slug
        doc.install($.noop, $.noop) if doc.isOutdated(status)
      return
    return
