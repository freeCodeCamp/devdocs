class app.DB
  NAME = 'docs'

  constructor: ->
    @useIndexedDB = @useIndexedDB()

  db: (fn) ->
    return fn @_db unless @useIndexedDB and @_db is undefined

    if @callback isnt undefined
      _callback = @callback
      @callback = =>
        _callback()
        fn @_db
        return
      return

    @callback = =>
      @_db ?= false
      delete @callback
      fn @_db
      return

    try
      req = indexedDB.open(NAME, @indexedDBVersion())
      req.onerror = @callback
      req.onsuccess = @onOpenSuccess
      req.onupgradeneeded = @onUpgradeNeeded
    catch
      @callback()
    return

  onOpenSuccess: (event) =>
    try
      @_db = event.target.result
      @_db.transaction(['docs', app.docs.all()[0].slug], 'readwrite').abort() # https://bugs.webkit.org/show_bug.cgi?id=136937
    catch
      @_db = false

    @callback()
    return

  onUpgradeNeeded: (event) =>
    db = event.target.result

    unless db.objectStoreNames.contains('docs')
      db.createObjectStore('docs')

    for doc in app.docs.all() when not db.objectStoreNames.contains(doc.slug)
      db.createObjectStore(doc.slug)

    for doc in app.disabledDocs.all() when not db.objectStoreNames.contains(doc.slug)
      db.createObjectStore(doc.slug)
    return

  store: (doc, data, onSuccess, onError) ->
    @db (db) ->
      unless db
        onError()
        return

      txn = db.transaction ['docs', doc.slug], 'readwrite'
      txn.oncomplete = -> if txn.error then onError() else onSuccess()

      store = txn.objectStore(doc.slug)
      store.clear()
      store.add(content, path) for path, content of data

      store = txn.objectStore('docs')
      store.put(doc.mtime, doc.slug)
      return
    return

  unstore: (doc, onSuccess, onError) ->
    @db (db) ->
      unless db
        onError()
        return

      txn = db.transaction ['docs', doc.slug], 'readwrite'
      txn.oncomplete = -> if txn.error then onError() else onSuccess()

      store = txn.objectStore(doc.slug)
      store.clear()

      store = txn.objectStore('docs')
      store.delete(doc.slug)
      return
    return

  version: (doc, fn) ->
    @db (db) ->
      unless db
        fn(false)
        return

      txn = db.transaction ['docs'], 'readonly'
      store = txn.objectStore('docs')

      req = store.get(doc.slug)
      req.onsuccess = -> fn(req.result)
      req.onerror = -> fn(false)
      return
    return

  versions: (docs, fn) ->
    @db (db) ->
      result = {}

      unless db
        result[doc.slug] = false for doc in docs
        fn(result)
        return

      txn = db.transaction ['docs'], 'readonly'
      txn.oncomplete = -> fn(result)
      store = txn.objectStore('docs')

      docs.forEach (doc) ->
        req = store.get(doc.slug)
        req.onsuccess = -> result[doc.slug] = req.result
        req.onerror = -> result[doc.slug] = false
        return
      return

  load: (entry, onSuccess, onError) ->
    if @useIndexedDB and @_db isnt false
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
    @db (db) ->
      unless db
        onError()
        return

      txn = db.transaction [entry.doc.slug], 'readonly'
      store = txn.objectStore(entry.doc.slug)

      req = store.get(entry.path)
      req.onsuccess = -> if req.result then onSuccess(req.result) else onError()
      req.onerror = onError

      txn

  reset: ->
    try indexedDB?.deleteDatabase(NAME) catch

  useIndexedDB: ->
    !app.isSingleDoc() and !!window.indexedDB

  indexedDBVersion: ->
    if app.config.env is 'production' then app.config.version else Date.now() / 1000
