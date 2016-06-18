class @CookieStore
  INT = /^\d+$/

  get: (key) ->
    try
      value = Cookies.get(key)
      value = parseInt(value, 10) if value? and INT.test(value)
      value
    catch

  set: (key, value) ->
    if value == false
      return @del(key)
    else if value == true
      value = 1

    try
      Cookies.set(key, '' + value, path: '/', expires: 1e8)
      true
    catch

  del: (key) ->
    try
      Cookies.expire(key)
      true
    catch

  reset: ->
    try
      for cookie in document.cookie.split(/;\s?/)
        Cookies.expire(cookie.split('=')[0])
      return
    catch

  dump: ->
    result = {}
    for cookie in document.cookie.split(/;\s?/)
      cookie = cookie.split('=')
      result[cookie[0]] = cookie[1]
    result
