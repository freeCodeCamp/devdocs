#= require app/searcher

class app.models.Entry extends app.Model
  # Attributes: name, type, path

  constructor: ->
    super
    @text = applyAliases(app.Searcher.normalizeString(@name))

  addAlias: (name) ->
    text = applyAliases(app.Searcher.normalizeString(name))
    @text = [@text] unless Array.isArray(@text)
    @text.push(if Array.isArray(text) then text[1] else text)
    return

  fullPath: ->
    @doc.fullPath if @isIndex() then '' else @path

  dbPath: ->
    @path.replace /#.*/, ''

  filePath: ->
    @doc.fullPath @_filePath()

  fileUrl: ->
    @doc.fileUrl @_filePath()

  _filePath: ->
    result = @path.replace /#.*/, ''
    result += '.html' unless result[-5..-1] is '.html'
    result

  isIndex: ->
    @path is 'index'

  getType: ->
    @doc.types.findBy 'name', @type

  loadFile: (onSuccess, onError) ->
    app.db.load(@, onSuccess, onError)

  applyAliases = (string) ->
    if ALIASES.hasOwnProperty(string)
      return [string, ALIASES[string]]
    else
      words = string.split('.')
      for word, i in words when ALIASES.hasOwnProperty(word)
        words[i] = ALIASES[word]
        return [string, words.join('.')]
    return string

  @ALIASES = ALIASES =
    'angular': 'ng'
    'angular.js': 'ng'
    'backbone.js': 'bb'
    'c++': 'cpp'
    'coffeescript': 'cs'
    'crystal': 'cr'
    'elixir': 'ex'
    'javascript': 'js'
    'julia': 'jl'
    'jquery': '$'
    'knockout.js': 'ko'
    'less': 'ls'
    'lodash': '_'
    'löve': 'love'
    'marionette': 'mn'
    'markdown': 'md'
    'modernizr': 'mdr'
    'moment.js': 'mt'
    'openjdk': 'java'
    'nginx': 'ngx'
    'numpy': 'np'
    'pandas': 'pd'
    'postgresql': 'pg'
    'python': 'py'
    'ruby.on.rails': 'ror'
    'ruby': 'rb'
    'rust': 'rs'
    'sass': 'scss'
    'tensorflow': 'tf'
    'typescript': 'ts'
    'underscore.js': '_'
