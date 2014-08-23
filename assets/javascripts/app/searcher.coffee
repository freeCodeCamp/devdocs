class app.Searcher
  $.extend @prototype, Events

  CHUNK_SIZE = 10000
  SEPARATOR = '.'

  DEFAULTS =
    max_results: app.config.max_results
    fuzzy_min_length: 3

  constructor: (options = {}) ->
    @options = $.extend {}, DEFAULTS, options

  find: (data, attr, query) ->
    @kill()

    @data = data
    @attr = attr
    @query = query
    @setup()

    if @isValid() then @match() else @end()
    return

  setup: ->
    @query = @normalizeQuery @query
    @queryLength = @query.length
    @dataLength = @data.length
    @matchers = ['exactMatch']
    @totalResults = 0
    @setupFuzzy()
    return

  setupFuzzy: ->
    if @queryLength >= @options.fuzzy_min_length
      @fuzzyRegexp = @queryToFuzzyRegexp @query
      @matchers.push 'fuzzyMatch'
    return

  isValid: ->
    @queryLength > 0

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
    @data = @attr = @query = @queryLength = @dataLength =
    @fuzzyRegexp = @matchers = @totalResults = @scoreMap =
    @cursor = @matcher = @timeout = null
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
    for [0...@chunkSize()]
      if score = @[@matcher](@data[@cursor][@attr])
        @addResult @data[@cursor], score
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

  normalizeQuery: (string) ->
    string.replace(/\s/g, '').toLowerCase()

  queryToFuzzyRegexp: (string) ->
    chars = string.split ''
    chars[i] = $.escapeRegexp(char) for char, i in chars
    new RegExp chars.join('.*?') # abc -> /a.*?b.*?c.*?/

  #
  # Match functions
  #

  index =      # position of the query in the string being matched
  lastIndex =  # last position of the query in the string being matched
  match =      # regexp match data
  score =      # score for the current match
  separators = # counter
  i = null     # cursor

  exactMatch: (value) ->
    index = value.indexOf @query
    return unless index >= 0

    lastIndex = value.lastIndexOf @query

    if index isnt lastIndex
      Math.max(@scoreExactMatch(value, index), @scoreExactMatch(value, lastIndex))
    else
      @scoreExactMatch(value, index)

  scoreExactMatch: (value, index) ->
    # Remove one point for each unmatched character.
    score = 100 - (value.length - @queryLength)

    if index > 0
      # If the character preceding the query is a dot, assign the same score
      # as if the query was found at the beginning of the string, minus one.
      if value[index - 1] is SEPARATOR
        score += index - 1
      # Don't match a single-character query unless it's found at the beginning
      # of the string or is preceded by a dot.
      else if @queryLength is 1
        return
      # (1) Remove one point for each unmatched character up to the nearest
      #     preceding dot or the beginning of the string.
      # (2) Remove one point for each unmatched character following the query.
      else
        i = index - 2
        i-- while i >= 0 and value[i] isnt SEPARATOR
        score -= (index - i) +                         # (1)
                 (value.length - @queryLength - index) # (2)

      # Remove one point for each dot preceding the query, except for the one
      # immediately before the query.
      separators = 0
      i = index - 2
      while i >= 0
        separators++ if value[i] is SEPARATOR
        i--
      score -= separators

    # Remove five points for each dot following the query.
    separators = 0
    i = value.length - @queryLength - index - 1
    while i >= 0
      separators++ if value[index + @queryLength + i] is SEPARATOR
      i--
    score -= separators * 5

    Math.max 1, score

  fuzzyMatch: (value) ->
    return if value.length <= @queryLength or value.indexOf(@query) >= 0
    return unless match = @fuzzyRegexp.exec(value)

    # When the match is at the beginning of the string or preceded by a dot.
    if match.index is 0 or value[match.index - 1] is SEPARATOR
      Math.max 66, 100 - match[0].length
    # When the match is at the end of the string.
    else if match.index + match[0].length is value.length
      Math.max 33, 67 - match[0].length
    # When the match is in the middle of the string.
    else
      Math.max 1, 34 - match[0].length

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
