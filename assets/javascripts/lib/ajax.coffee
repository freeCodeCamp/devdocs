MIME_TYPES =
  json: 'application/json'
  html: 'text/html'

@ajax = (options) ->
  applyDefaults(options)
  serializeData(options)

  abortController = new AbortController()

  timer = setTimeout =>
    abortController.abort()
  , options.timeout * 1000

  fetch(
    options.url,
    headers: processHeaders(options)
    method: options.type
    contentType: options.dataType
    signal: abortController.signal
  ).then((response) ->
    if options.dataType == 'json'
      response.json()
    else
      response.text()
  ).then((data) ->
    if data?
      onSuccess data, options
    else
      onError 'invalid', '', options
  ).catch((error) ->
    onError 'error', error, options
  ).finally ->
    clearTimeout timer

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

processHeaders = (options) ->
  options.headers or= {}

  if options.contentType
    options.headers['Content-Type'] = options.contentType

  if not options.headers['Content-Type'] and options.data and options.type isnt 'GET'
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded'

  if options.dataType
    options.headers['Accept'] = MIME_TYPES[options.dataType] or options.dataType
  return options.headers

onSuccess = (data, options) ->
  options.success?.call options.context, data, options
  return

onError = (type, error, options) ->
  options.error?.call options.context, type, error, options
  return

