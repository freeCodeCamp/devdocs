class app.Settings
  hasDocs: ->
    try
      !!Cookies.get 'docs'
    catch

  getDocs: ->
    try
      Cookies.get('docs')?.split('/') or app.config.default_docs
    catch
      app.config.default_docs

  setDocs: (docs) ->
    try
      Cookies.set 'docs', docs.join('/'),
        path: '/'
        expires: 1e8
    catch
    return

  reset: ->
    try
      Cookies.expire 'docs'
    catch
    return
