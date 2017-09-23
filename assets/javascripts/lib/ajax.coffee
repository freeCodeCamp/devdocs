MIME_TYPES =
  json: 'application/json'
  html: 'text/html'

@ajax = (options) ->
  applyDefaults(options)
  serializeData(options)

  xhr = new XMLHttpRequest()
  xhr.open(options.type, options.url, options.async)

  applyCallbacks(xhr, options)
  applyHeaders(xhr, options)

  xhr.send(options.data)

  if options.async
    abort: abort.bind(undefined, xhr)
  else
    parseResponse(xhr, options)

ajax.defaults =
  async: true
  dataType: 'json'
  timeout: 30
  type: 'GET'
  # contentType
  # context
  # data
  # error
  # headers
  # progress
  # success
  # url

applyDefaults = (options) ->
  for key of ajax.defaults
    options[key] ?= ajax.defaults[key]
  return

serializeData = (options) ->
  return unless options.data

  if options.type is 'GET'
    options.url += '?' + serializeParams(options.data)
    options.data = null
  else
    options.data = serializeParams(options.data)
  return

serializeParams = (params) ->
  ("#{encodeURIComponent key}=#{encodeURIComponent value}" for key, value of params).join '&'

applyCallbacks = (xhr, options) ->
  return unless options.async

  xhr.timer = setTimeout onTimeout.bind(undefined, xhr, options), options.timeout * 1000
  xhr.onprogress = options.progress if options.progress
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      clearTimeout(xhr.timer)
      onComplete(xhr, options)
    return
  return

applyHeaders = (xhr, options) ->
  options.headers or= {}

  if options.contentType
    options.headers['Content-Type'] = options.contentType

  if not options.headers['Content-Type'] and options.data and options.type isnt 'GET'
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded'

  if options.dataType
    options.headers['Accept'] = MIME_TYPES[options.dataType] or options.dataType

  for key, value of options.headers
    xhr.setRequestHeader(key, value)
  return

onComplete = (xhr, options) ->
  if 200 <= xhr.status < 300
    if (response = parseResponse(xhr, options))?
      onSuccess response, xhr, options
    else
      onError 'invalid', xhr, options
  else
    onError 'error', xhr, options
  return

onSuccess = (response, xhr, options) ->
  options.success?.call options.context, response, xhr, options
  return

onError = (type, xhr, options) ->
  options.error?.call options.context, type, xhr, options
  return

onTimeout = (xhr, options) ->
  xhr.abort()
  onError 'timeout', xhr, options
  return

abort = (xhr) ->
  clearTimeout(xhr.timer)
  xhr.onreadystatechange = null
  xhr.abort()
  return

parseResponse = (xhr, options) ->
  if options.dataType is 'json'
    parseJSON(xhr.responseText)
  else
    xhr.responseText

parseJSON = (json) ->
  try JSON.parse(json) catch
