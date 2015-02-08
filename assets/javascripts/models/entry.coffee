#= require app/searcher

class app.models.Entry extends app.Model
  # Attributes: name, type, path

  constructor: ->
    super
    @text = app.Searcher.normalizeString(@name)

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
