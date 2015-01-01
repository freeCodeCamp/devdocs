class app.models.Doc extends app.Model
  # Attributes: name, slug, type, version, index_path, db_path, mtime

  constructor: ->
    super
    @reset @

  reset: (data) ->
    @resetEntries data.entries
    @resetTypes data.types
    return

  resetEntries: (entries) ->
    @entries = new app.collections.Entries(entries)
    @entries.each (entry) => entry.doc = @
    return

  resetTypes: (types) ->
    @types = new app.collections.Types(types)
    @types.each (type) => type.doc = @
    return

  fullPath: (path = '') ->
    path = "/#{path}" unless path[0] is '/'
    "/#{@slug}#{path}"

  fileUrl: (path) ->
    "#{app.config.docs_host}#{@fullPath(path)}"

  dbUrl: ->
    "#{app.config.docs_host}/#{@db_path}?#{@mtime}"

  indexUrl: ->
    "#{app.indexHost()}/#{@index_path}?#{@mtime}"

  toEntry: ->
    new app.models.Entry
      doc: @
      name: @name
      path: 'index'

  findEntryByPathAndHash: (path, hash) ->
    if hash and entry = @entries.findBy 'path', "#{path}##{hash}"
      entry
    else if path is 'index'
      @toEntry()
    else
      @entries.findBy 'path', path

  load: (onSuccess, onError, options = {}) ->
    return if options.readCache and @_loadFromCache(onSuccess)

    callback = (data) =>
      @reset data
      onSuccess()
      @_setCache data if options.writeCache
      return

    ajax
      url: @indexUrl()
      success: callback
      error: onError

  clearCache: ->
    app.store.del @slug
    return

  _loadFromCache: (onSuccess) ->
    return unless data = @_getCache()

    callback = =>
      @reset data
      onSuccess()
      return

    setTimeout callback, 0
    true

  _getCache: ->
    return unless data = app.store.get @slug

    if data[0] is @mtime
      return data[1]
    else
      @clearCache()
      return

  _setCache: (data) ->
    app.store.set @slug, [@mtime, data]
    return

  download: (onSuccess, onError) ->
    return if @downloading
    @downloading = true

    error = =>
      @downloading = null
      onError()
      return

    success = (data) =>
      @downloading = null
      app.db.store @, data, onSuccess, error
      return

    ajax
      url: @dbUrl()
      success: success
      error: error
    return

  undownload: (onSuccess, onError) ->
    return if @downloading
    @downloading = true

    success = =>
      @downloading = null
      onSuccess()
      return

    error = =>
      @downloading = null
      onError()
      return

    app.db.unstore @, success, error
    return

  getDownloadStatus: (callback) ->
    app.db.version @, (value) ->
      callback downloaded: !!value, version: value
    return
