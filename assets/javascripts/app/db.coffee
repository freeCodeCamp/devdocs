class app.DB
  NAME = 'docs'

  constructor: ->
    @useIndexedDB = @useIndexedDB()
    @indexedDBVersion = @indexedDBVersion()
    @callbacks = []

  db: (fn) ->
    return fn() unless @useIndexedDB
    @callbacks.push(fn) if fn
    return if @open

    try
      @open = true
      req = indexedDB.open(NAME, @indexedDBVersion)
      req.onsuccess = @onOpenSuccess
      req.onerror = @onOpenError
      req.onupgradeneeded = @onUpgradeNeeded
    catch
      @onOpenError()
    return

  onOpenSuccess: (event) =>
    try
      db = event.target.result
      unless @checkedBuggyIDB
        @idbTransaction(db, stores: ['docs', app.docs.all()[0].slug], mode: 'readwrite').abort() # https://bugs.webkit.org/show_bug.cgi?id=136937
        @checkedBuggyIDB = true
    catch
      try db.close()
      @reason = 'apple'
      @onOpenError()
      return

    @runCallbacks(db)
    @open = false
    db.close()
    return

  onOpenError: (event) =>
    event?.preventDefault()
    @open = false

    if event?.target?.error?.name is 'QuotaExceededError'
      @reset()
      @db()
      app.onQuotaExceeded()
    else
      @useIndexedDB = false
      @reason or= 'cant_open'
      @runCallbacks()
    return

  runCallbacks: (db) ->
    fn(db) while fn = @callbacks.shift()
    return

  onUpgradeNeeded: (event) ->
    return unless db = event.target.result

    unless db.objectStoreNames.contains('docs')
      db.createObjectStore('docs')

    for doc in app.docs.all() when not db.objectStoreNames.contains(doc.slug)
      db.createObjectStore(doc.slug)

    for doc in app.disabledDocs.all() when not db.objectStoreNames.contains(doc.slug)
      db.createObjectStore(doc.slug)
    return

  store: (doc, data, onSuccess, onError) ->
    @db (db) =>
      unless db
        onError()
        return

      txn = @idbTransaction db, stores: ['docs', doc.slug], mode: 'readwrite', ignoreError: false
      txn.oncomplete = =>
        @cachedDocs?[doc.slug] = doc.mtime
        onSuccess()
        return
      txn.onerror = (event) ->
        event.preventDefault()
        onError(event)
        return

      store = txn.objectStore(doc.slug)
      store.clear()
      store.add(content, path) for path, content of data

      store = txn.objectStore('docs')
      store.put(doc.mtime, doc.slug)
      return
    return

  unstore: (doc, onSuccess, onError) ->
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
        onError(event)
        return

      store = txn.objectStore(doc.slug)
      store.clear()

      store = txn.objectStore('docs')
      store.delete(doc.slug)
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
      @loadDocsCache(db) unless @cachedDocs
      return

  loadDocsCache: (db) ->
    @cachedDocs = {}

    txn = @idbTransaction db, stores: ['docs'], mode: 'readonly'
    store = txn.objectStore('docs')

    req = store.openCursor()
    req.onsuccess = (event) =>
      return unless cursor = event.target.result
      @cachedDocs[cursor.key] = cursor.value
      cursor.continue()
      return
    req.onerror = (event) ->
      event.preventDefault()
      return
    return

  shouldLoadWithIDB: (entry) ->
    @useIndexedDB and (not @cachedDocs or @cachedDocs[entry.doc.slug])

  idbTransaction: (db, options) ->
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

  indexedDBVersion: ->
    if app.config.env is 'production' then parseInt(app.config.version, 10) else Date.now() / 1000
