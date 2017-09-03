#
# Match functions
#

SEPARATOR = '.'

query =
queryLength =
value =
valueLength =
matcher =     # current match function
fuzzyRegexp = # query fuzzy regexp
index =       # position of the query in the string being matched
lastIndex =   # last position of the query in the string being matched
match =       # regexp match data
matchIndex =
matchLength =
score =       # score for the current match
separators =  # counter
i = null      # cursor

`function exactMatch() {`
index = value.indexOf(query)
return unless index >= 0

lastIndex = value.lastIndexOf(query)

if index isnt lastIndex
  return Math.max(scoreExactMatch(), ((index = lastIndex) and scoreExactMatch()) or 0)
else
  return scoreExactMatch()
`}`

`function scoreExactMatch() {`
# Remove one point for each unmatched character.
score = 100 - (valueLength - queryLength)

if index > 0
  # If the character preceding the query is a dot, assign the same score
  # as if the query was found at the beginning of the string, minus one.
  if value.charAt(index - 1) is SEPARATOR
    score += index - 1
  # Don't match a single-character query unless it's found at the beginning
  # of the string or is preceded by a dot.
  else if queryLength is 1
    return
  # (1) Remove one point for each unmatched character up to the nearest
  #     preceding dot or the beginning of the string.
  # (2) Remove one point for each unmatched character following the query.
  else
    i = index - 2
    i-- while i >= 0 and value.charAt(i) isnt SEPARATOR
    score -= (index - i) +                       # (1)
             (valueLength - queryLength - index) # (2)

  # Remove one point for each dot preceding the query, except for the one
  # immediately before the query.
  separators = 0
  i = index - 2
  while i >= 0
    separators++ if value.charAt(i) is SEPARATOR
    i--
  score -= separators

# Remove five points for each dot following the query.
separators = 0
i = valueLength - queryLength - index - 1
while i >= 0
  separators++ if value.charAt(index + queryLength + i) is SEPARATOR
  i--
score -= separators * 5

return Math.max 1, score
`}`

`function fuzzyMatch() {`
return if valueLength <= queryLength or value.indexOf(query) >= 0
return unless match = fuzzyRegexp.exec(value)
matchIndex = match.index
matchLength = match[0].length
score = scoreFuzzyMatch()
if match = fuzzyRegexp.exec(value.slice(i = value.lastIndexOf(SEPARATOR) + 1))
  matchIndex = i + match.index
  matchLength = match[0].length
  return Math.max(score, scoreFuzzyMatch())
else
  return score
`}`

`function scoreFuzzyMatch() {`
# When the match is at the beginning of the string or preceded by a dot.
if matchIndex is 0 or value.charAt(matchIndex - 1) is SEPARATOR
  return Math.max 66, 100 - matchLength
# When the match is at the end of the string.
else if matchIndex + matchLength is valueLength
  return Math.max 33, 67 - matchLength
# When the match is in the middle of the string.
else
  return Math.max 1, 34 - matchLength
`}`

#
# Searchers
#

class app.Searcher
  $.extend @prototype, Events

  CHUNK_SIZE = 20000

  DEFAULTS =
    max_results: app.config.max_results
    fuzzy_min_length: 3

  SEPARATORS_REGEXP = /#|::|:-|->|\$(?=\w)|\-(?=\w)|\:(?=\w)|\ [\/\-&]\ |:\ |\ /g
  EOS_SEPARATORS_REGEXP = /(\w)[\-:]$/
  INFO_PARANTHESES_REGEXP = /\ \(\w+?\)$/
  EMPTY_PARANTHESES_REGEXP = /\(\)/
  EVENT_REGEXP = /\ event$/
  DOT_REGEXP = /\.+/g
  WHITESPACE_REGEXP = /\s/g

  EMPTY_STRING = ''
  ELLIPSIS = '...'
  STRING = 'string'

  @normalizeString: (string) ->
    string
      .toLowerCase()
      .replace ELLIPSIS, EMPTY_STRING
      .replace EVENT_REGEXP, EMPTY_STRING
      .replace INFO_PARANTHESES_REGEXP, EMPTY_STRING
      .replace SEPARATORS_REGEXP, SEPARATOR
      .replace DOT_REGEXP, SEPARATOR
      .replace EMPTY_PARANTHESES_REGEXP, EMPTY_STRING
      .replace WHITESPACE_REGEXP, EMPTY_STRING

  @normalizeQuery: (string) ->
    string = @normalizeString(string)
    string.replace EOS_SEPARATORS_REGEXP, '$1.'

  constructor: (options = {}) ->
    @options = $.extend {}, DEFAULTS, options

  find: (data, attr, q) ->
    @kill()

    @data = data
    @attr = attr
    @query = q
    @setup()

    if @isValid() then @match() else @end()
    return

  setup: ->
    query = @query = @constructor.normalizeQuery(@query)
    queryLength = query.length
    @dataLength = @data.length
    @matchers = [exactMatch]
    @totalResults = 0
    @setupFuzzy()
    return

  setupFuzzy: ->
    if queryLength >= @options.fuzzy_min_length
      fuzzyRegexp = @queryToFuzzyRegexp(query)
      @matchers.push(fuzzyMatch)
    else
      fuzzyRegexp = null
    return

  isValid: ->
    queryLength > 0 and query isnt SEPARATOR

  end: ->
    @triggerResults [] unless @totalResults
    @trigger 'end'
    @free()
    return

  kill: ->
    if @timeout
      clearTimeout @timeout
      @free()
    return

  free: ->
    @data = @attr = @dataLength = @matchers = @matcher = @query =
    @totalResults = @scoreMap = @cursor = @timeout = null
    return

  match: =>
    if not @foundEnough() and @matcher = @matchers.shift()
      @setupMatcher()
      @matchChunks()
    else
      @end()
    return

  setupMatcher: ->
    @cursor = 0
    @scoreMap = new Array(101)
    return

  matchChunks: =>
    @matchChunk()

    if @cursor is @dataLength or @scoredEnough()
      @delay @match
      @sendResults()
    else
      @delay @matchChunks
    return

  matchChunk: ->
    matcher = @matcher
    for [0...@chunkSize()]
      value = @data[@cursor][@attr]
      if value.split # string
        valueLength = value.length
        @addResult(@data[@cursor], score) if score = matcher()
      else # array
        score = 0
        for value in @data[@cursor][@attr]
          valueLength = value.length
          score = Math.max(score, matcher() || 0)
        @addResult(@data[@cursor], score) if score > 0
      @cursor++
    return

  chunkSize: ->
    if @cursor + CHUNK_SIZE > @dataLength
      @dataLength % CHUNK_SIZE
    else
      CHUNK_SIZE

  scoredEnough: ->
     @scoreMap[100]?.length >= @options.max_results

  foundEnough: ->
    @totalResults >= @options.max_results

  addResult: (object, score) ->
    (@scoreMap[Math.round(score)] or= []).push(object)
    @totalResults++
    return

  getResults: ->
    results = []
    for objects in @scoreMap by -1 when objects
      results.push.apply results, objects
    results[0...@options.max_results]

  sendResults: ->
    results = @getResults()
    @triggerResults results if results.length
    return

  triggerResults: (results) ->
    @trigger 'results', results
    return

  delay: (fn) ->
    @timeout = setTimeout(fn, 1)

  queryToFuzzyRegexp: (string) ->
    chars = string.split ''
    chars[i] = $.escapeRegexp(char) for char, i in chars
    new RegExp chars.join('.*?') # abc -> /a.*?b.*?c.*?/

class app.SynchronousSearcher extends app.Searcher
  match: =>
    if @matcher
      @allResults or= []
      @allResults.push.apply @allResults, @getResults()
    super

  free: ->
    @allResults = null
    super

  end: ->
    @sendResults true
    super

  sendResults: (end) ->
    if end and @allResults?.length
      @triggerResults @allResults

  delay: (fn) ->
    fn()
