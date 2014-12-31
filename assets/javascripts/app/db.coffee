class app.DB
  NAME = 'docs'

  constructor: ->
    @useIndexedDB = @useIndexedDB()

  init: (@_callback) ->
    if @useIndexedDB
      @initIndexedDB()
    else
      @callback()
    return

  initIndexedDB: ->
    try
      req = indexedDB.open(NAME, @indexedDBVersion())
      req.onerror = @callback
      req.onsuccess = @onOpenSuccess
      req.onupgradeneeded = @onUpgradeNeeded
    catch
      @callback()
    return

  isEnabled: ->
    !!@db

  callback: =>
    @_callback?()
    @_callback = null
    return

  onOpenSuccess: (event) =>
    try
      @db = event.target.result
      @db.transaction(['docs', app.docs.all()[0].slug], 'readwrite').abort() # https://bugs.webkit.org/show_bug.cgi?id=136937
    catch
      @db = null

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
    txn = @db.transaction ['docs', doc.slug], 'readwrite'
    txn.oncomplete = -> if txn.error then onError() else onSuccess()

    store = txn.objectStore(doc.slug)
    store.clear()
    store.add(content, path) for path, content of data

    store = txn.objectStore('docs')
    store.put(doc.mtime, doc.slug)
    return

  unstore: (doc, onSuccess, onError) ->
    txn = @db.transaction ['docs', doc.slug], 'readwrite'
    txn.oncomplete = -> if txn.error then onError() else onSuccess()

    store = txn.objectStore(doc.slug)
    store.clear()

    store = txn.objectStore('docs')
    store.delete(doc.slug)
    return

  version: (doc, callback) ->
    txn = @db.transaction ['docs'], 'readonly'
    store = txn.objectStore('docs')

    req = store.get(doc.slug)
    req.onsuccess = -> callback(!!req.result)
    req.onerror = -> callback(false)
    return

  load: (entry, onSuccess, onError) ->
    if @isEnabled()
      onError = @loadWithXHR.bind(@, entry, onSuccess, onError)
      @loadWithIDB(entry, onSuccess, onError)
    else
      @loadWithXHR(entry, onSuccess, onError)

  loadWithXHR: (entry, onSuccess, onError) ->
    ajax
      url: entry.fileUrl()
      dataType: 'html'
      success: onSuccess
      error: onError

  loadWithIDB: (entry, onSuccess, onError) ->
    txn = @db.transaction [entry.doc.slug], 'readonly'
    store = txn.objectStore(entry.doc.slug)

    req = store.get(entry.path)
    req.onsuccess = -> if req.result then onSuccess(req.result) else onError()
    req.onerror = onError

    txn

  useIndexedDB: ->
    !app.isSingleDoc() and !!window.indexedDB

  indexedDBVersion: ->
    if app.config.env is 'production' then app.config.version else Date.now() / 1000
