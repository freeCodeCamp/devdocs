class app.models.Doc extends app.Model
  # Attributes: name, slug, type, version, release, db_size, mtime, links

  constructor: ->
    super
    @reset @
    @slug_without_version = @slug.split('~')[0]
    @fullName = "#{@name}" + if @version then " #{@version}" else ''
    @icon = @slug_without_version
    @short_version = @version.split(' ')[0] if @version
    @text = @toEntry().text

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
    "#{app.config.docs_origin}#{@fullPath(path)}?#{@mtime}"

  dbUrl: ->
    "#{app.config.docs_origin}/#{@slug}/#{app.config.db_filename}?#{@mtime}"

  indexUrl: ->
    "#{app.indexHost()}/#{@slug}/#{app.config.index_filename}?#{@mtime}"

  toEntry: ->
    return @entry if @entry
    @entry = new app.models.Entry
      doc: @
      name: @fullName
      path: 'index'
    @entry.addAlias(@name) if @version
    @entry

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
    app.localStorage.del @slug
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
    return unless data = app.localStorage.get @slug

    if data[0] is @mtime
      return data[1]
    else
      @clearCache()
      return

  _setCache: (data) ->
    app.localStorage.set @slug, [@mtime, data]
    return

  install: (onSuccess, onError, onProgress) ->
    return if @installing
    @installing = true

    error = =>
      @installing = null
      onError()
      return

    success = (data) =>
      @installing = null
      app.db.store @, data, onSuccess, error
      return

    ajax
      url: @dbUrl()
      success: success
      error: error
      progress: onProgress
      timeout: 3600
    return

  uninstall: (onSuccess, onError) ->
    return if @installing
    @installing = true

    success = =>
      @installing = null
      onSuccess()
      return

    error = =>
      @installing = null
      onError()
      return

    app.db.unstore @, success, error
    return

  getInstallStatus: (callback) ->
    app.db.version @, (value) ->
      callback installed: !!value, mtime: value
    return

  isOutdated: (status) ->
    status and status.installed and @mtime isnt status.mtime
