return unless console?.time and console.groupCollapsed

#
# App
#

_init = app.init
app.init = ->
  console.time 'Init'
  _init.call(app)
  console.timeEnd 'Init'
  console.time 'Load'

_start = app.start
app.start = ->
  console.timeEnd 'Load'
  console.time 'Start'
  _start.call(app, arguments...)
  console.timeEnd 'Start'

#
# Searcher
#

_super = app.Searcher
_proto = app.Searcher.prototype

app.Searcher = ->
  _super.apply @, arguments

  _setup = @setup.bind(@)
  @setup = ->
    console.groupCollapsed "Search: #{@query}"
    console.time 'Total'
    _setup()

  _match = @match.bind(@)
  @match = =>
    console.timeEnd @matcher.name if @matcher
    _match()

  _setupMatcher = @setupMatcher.bind(@)
  @setupMatcher = ->
    console.time @matcher.name
    _setupMatcher()

  _end = @end.bind(@)
  @end = ->
    console.log "Results: #{@totalResults}"
    console.timeEnd 'Total'
    console.groupEnd()
    _end()

  _kill = @kill.bind(@)
  @kill = ->
    if @timeout
      console.timeEnd @matcher.name if @matcher
      console.groupEnd()
      console.timeEnd 'Total'
      console.warn 'Killed'
    _kill()

  return

$.extend(app.Searcher, _super)
_proto.constructor = app.Searcher
app.Searcher.prototype = _proto

#
# View tree
#

@viewTree = (view = app.document, level = 0, visited = []) ->
  return if visited.indexOf(view) >= 0
  visited.push(view)

  console.log "%c #{Array(level + 1).join('  ')}#{view.constructor.name}: #{!!view.activated}",
              'color:' + (view.activated and 'green' or 'red')

  for own key, value of view when key isnt 'view' and value
    if typeof value is 'object' and value.setupElement
      @viewTree(value, level + 1, visited)
    else if value.constructor.toString().match(/Object\(\)/)
      @viewTree(v, level + 1, visited) for own k, v of value when v and typeof v is 'object' and v.setupElement
  return
