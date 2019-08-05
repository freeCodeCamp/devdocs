class @CookiesStore
  # Intentionally called CookiesStore instead of CookieStore
  # Calling it CookieStore causes issues when the Experimental Web Platform features flag is enabled in Chrome
  # Related issue: https://github.com/freeCodeCamp/devdocs/issues/932

  INT = /^\d+$/

  @onBlocked: ->

  get: (key) ->
    value = Cookies.get(key)
    value = parseInt(value, 10) if value? and INT.test(value)
    value

  set: (key, value) ->
    if value == false
      @del(key)
      return

    value = 1 if value == true
    value = parseInt(value, 10) if value and INT.test?(value)
    Cookies.set(key, '' + value, path: '/', expires: 1e8)
    @constructor.onBlocked(key, value, @get(key)) if @get(key) != value
    return

  del: (key) ->
    Cookies.expire(key)
    return

  reset: ->
    try
      for cookie in document.cookie.split(/;\s?/)
        Cookies.expire(cookie.split('=')[0])
      return
    catch

  dump: ->
    result = {}
    for cookie in document.cookie.split(/;\s?/) when cookie[0] isnt '_'
      cookie = cookie.split('=')
      result[cookie[0]] = cookie[1]
    result
