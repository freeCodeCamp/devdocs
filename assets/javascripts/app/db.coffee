class app.DB
  NAME = 'docs'
  VERSION = 15

  constructor: ->
    @versionMultipler = if $.isIE() then 1e5 else 1e9
    @useIndexedDB = @useIndexedDB()
    @callbacks = []

  db: (fn) ->
    return fn() unless @useIndexedDB
    @callbacks.push(fn) if fn
    return if @open

    try
      @open = true
      req = indexedDB.open(NAME, VERSION * @versionMultipler + @userVersion())
      req.onsuccess = @onOpenSuccess
      req.onerror = @onOpenError
      req.onupgradeneeded = @onUpgradeNeeded
    catch error
      @fail 'exception', error
    return

  onOpenSuccess: (event) =>
    db = event.target.result

    if db.objectStoreNames.length is 0
      try db.close()
      @open = false
      @fail 'empty'
    else if error = @buggyIDB(db)
      try db.close()
      @open = false
      @fail 'buggy', error
    else
      @runCallbacks(db)
      @open = false
      db.close()
    return

  onOpenError: (event) =>
    event.preventDefault()
    @open = false
    error = event.target.error

    switch error.name
      when 'QuotaExceededError'
        @onQuotaExceededError()
      when 'VersionError'
        @onVersionError()
      when 'InvalidStateError'
        @fail 'private_mode'
      else
        @fail 'cant_open', error
    return

  fail: (reason, error) ->
    @cachedDocs = null
    @useIndexedDB = false
    @reason or= reason
    @error or= error
    console.error? 'IDB error', error if error
    @runCallbacks()
    if error and reason is 'cant_open'
      Raven.captureMessage "#{error.name}: #{error.message}", level: 'warning', fingerprint: [error.name]
    return

  onQuotaExceededError: ->
    @reset()
    @db()
    app.onQuotaExceeded()
    Raven.captureMessage 'QuotaExceededError', level: 'warning'
    return

  onVersionError: ->
    req = indexedDB.open(NAME)
    req.onsuccess = (event) =>
      @handleVersionMismatch event.target.result.version
    req.onerror = (event) ->
      event.preventDefault()
      @fail 'cant_open', error
    return

  handleVersionMismatch: (actualVersion) ->
    if Math.floor(actualVersion / @versionMultipler) isnt VERSION
      @fail 'version'
    else
      @setUserVersion actualVersion - VERSION * @versionMultipler
      @db()
    return

  buggyIDB: (db) ->
    return if @checkedBuggyIDB
    @checkedBuggyIDB = true
    try
      @idbTransaction(db, stores: $.makeArray(db.objectStoreNames)[0..1], mode: 'readwrite').abort() # https://bugs.webkit.org/show_bug.cgi?id=136937
      return
    catch error
      return error

  runCallbacks: (db) ->
    fn(db) while fn = @callbacks.shift()
    return

  onUpgradeNeeded: (event) ->
    return unless db = event.target.result

    objectStoreNames = $.makeArray(db.objectStoreNames)

    unless $.arrayDelete(objectStoreNames, 'docs')
      try db.createObjectStore('docs')

    for doc in app.docs.all() when not $.arrayDelete(objectStoreNames, doc.slug)
      try db.createObjectStore(doc.slug)

    for name in objectStoreNames
      try db.deleteObjectStore(name)
    return

  store: (doc, data, onSuccess, onError, _retry = true) ->
    @db (db) =>
      unless db
        onError()
        return

      txn = @idbTransaction db, stores: ['docs', doc.slug], mode: 'readwrite', ignoreError: false
      txn.oncomplete = =>
        @cachedDocs?[doc.slug] = doc.mtime
        onSuccess()
        return
      txn.onerror = (event) =>
        event.preventDefault()
        if txn.error?.name is 'NotFoundError' and _retry
          @migrate()
          setTimeout =>
            @store(doc, data, onSuccess, onError, false)
          , 0
        else
          onError(event)
        return

      store = txn.objectStore(doc.slug)
      store.clear()
      store.add(content, path) for path, content of data

      store = txn.objectStore('docs')
      store.put(doc.mtime, doc.slug)
      return
    return

  unstore: (doc, onSuccess, onError, _retry = true) ->
    @db (db) =>
      unless db
        onError()
        return

      txn = @idbTransaction db, stores: ['docs', doc.slug], mode: 'readwrite', ignoreError: false
      txn.oncomplete = =>
        delete @cachedDocs?[doc.slug]
        onSuccess()
        return
      txn.onerror = (event) ->
        event.preventDefault()
        if txn.error?.name is 'NotFoundError' and _retry
          @migrate()
          setTimeout =>
            @unstore(doc, onSuccess, onError, false)
          , 0
        else
          onError(event)
        return

      store = txn.objectStore('docs')
      store.delete(doc.slug)

      store = txn.objectStore(doc.slug)
      store.clear()
      return
    return

  version: (doc, fn) ->
    if (version = @cachedVersion(doc))?
      fn(version)
      return

    @db (db) =>
      unless db
        fn(false)
        return

      txn = @idbTransaction db, stores: ['docs'], mode: 'readonly'
      store = txn.objectStore('docs')

      req = store.get(doc.slug)
      req.onsuccess = ->
        fn(req.result)
        return
      req.onerror = (event) ->
        event.preventDefault()
        fn(false)
        return
      return
    return

  cachedVersion: (doc) ->
    return unless @cachedDocs
    @cachedDocs[doc.slug] or false

  versions: (docs, fn) ->
    if versions = @cachedVersions(docs)
      fn(versions)
      return

    @db (db) =>
      unless db
        fn(false)
        return

      txn = @idbTransaction db, stores: ['docs'], mode: 'readonly'
      txn.oncomplete = ->
        fn(result)
        return
      store = txn.objectStore('docs')
      result = {}

      docs.forEach (doc) ->
        req = store.get(doc.slug)
        req.onsuccess = ->
          result[doc.slug] = req.result
          return
        req.onerror = (event) ->
          event.preventDefault()
          result[doc.slug] = false
          return
        return
      return

  cachedVersions: (docs) ->
    return unless @cachedDocs
    result = {}
    result[doc.slug] = @cachedVersion(doc) for doc in docs
    result

  load: (entry, onSuccess, onError) ->
    if @shouldLoadWithIDB(entry)
      onError = @loadWithXHR.bind(@, entry, onSuccess, onError)
      @loadWithIDB entry, onSuccess, onError
    else
      @loadWithXHR entry, onSuccess, onError

  loadWithXHR: (entry, onSuccess, onError) ->
    ajax
      url: entry.fileUrl()
      dataType: 'html'
      success: onSuccess
      error: onError

  loadWithIDB: (entry, onSuccess, onError) ->
    @db (db) =>
      unless db
        onError()
        return

      unless db.objectStoreNames.contains(entry.doc.slug)
        onError()
        @loadDocsCache(db)
        return

      txn = @idbTransaction db, stores: [entry.doc.slug], mode: 'readonly'
      store = txn.objectStore(entry.doc.slug)

      req = store.get(entry.dbPath())
      req.onsuccess = ->
        if req.result then onSuccess(req.result) else onError()
        return
      req.onerror = (event) ->
        event.preventDefault()
        onError()
        return
      @loadDocsCache(db)
      return

  loadDocsCache: (db) ->
    return if @cachedDocs
    @cachedDocs = {}

    txn = @idbTransaction db, stores: ['docs'], mode: 'readonly'
    txn.oncomplete = =>
      setTimeout(@checkForCorruptedDocs, 50)
      return

    req = txn.objectStore('docs').openCursor()
    req.onsuccess = (event) =>
      return unless cursor = event.target.result
      @cachedDocs[cursor.key] = cursor.value
      cursor.continue()
      return
    req.onerror = (event) ->
      event.preventDefault()
      return
    return

  checkForCorruptedDocs: =>
    @db (db) =>
      @corruptedDocs = []
      docs = (key for key, value of @cachedDocs when value)
      return if docs.length is 0

      for slug in docs when not app.docs.findBy('slug', slug)
        @corruptedDocs.push(slug)

      for slug in @corruptedDocs
        $.arrayDelete(docs, slug)

      if docs.length is 0
        setTimeout(@deleteCorruptedDocs, 0)
        return

      txn = @idbTransaction(db, stores: docs, mode: 'readonly', ignoreError: false)
      txn.oncomplete = =>
        setTimeout(@deleteCorruptedDocs, 0) if @corruptedDocs.length > 0
        return

      for doc in docs
        txn.objectStore(doc).get('index').onsuccess = (event) =>
          @corruptedDocs.push(event.target.source.name) unless event.target.result
          return
      return
    return

  deleteCorruptedDocs: =>
    @db (db) =>
      txn = @idbTransaction(db, stores: ['docs'], mode: 'readwrite', ignoreError: false)
      store = txn.objectStore('docs')
      while doc = @corruptedDocs.pop()
        @cachedDocs[doc] = false
        store.delete(doc)
      return
    Raven.captureMessage 'corruptedDocs', level: 'info', extra: { docs: @corruptedDocs.join(',') }
    return

  shouldLoadWithIDB: (entry) ->
    @useIndexedDB and (not @cachedDocs or @cachedDocs[entry.doc.slug])

  idbTransaction: (db, options) ->
    app.lastIDBTransaction = [options.stores, options.mode]
    txn = db.transaction(options.stores, options.mode)
    unless options.ignoreError is false
      txn.onerror = (event) ->
        event.preventDefault()
        return
    unless options.ignoreAbort is false
      txn.onabort = (event) ->
        event.preventDefault()
        return
    txn

  reset: ->
    try indexedDB?.deleteDatabase(NAME) catch
    return

  useIndexedDB: ->
    try
      if !app.isSingleDoc() and window.indexedDB
        true
      else
        @reason = 'not_supported'
        false
    catch
      false

  migrate: ->
    app.settings.set('schema', @userVersion() + 1)
    return

  setUserVersion: (version) ->
    app.settings.set('schema', version)
    return

  userVersion: ->
    app.settings.get('schema')
