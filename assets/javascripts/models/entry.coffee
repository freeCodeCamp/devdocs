class app.models.Entry extends app.Model
  # Attributes: name, type, path

  SEPARATORS_REGEXP = /\:?\ |#|::|->/g
  PARANTHESES_REGEXP = /\(.*?\)$/

  constructor: ->
    super
    @text = @searchValue()

  searchValue: ->
    @name
      .toLowerCase()
      .replace '...', ' '
      .replace /\ event$/, ''
      .replace SEPARATORS_REGEXP, '.'
      .replace /\.+/g, '.'
      .replace PARANTHESES_REGEXP, ''
      .trim()

  fullPath: ->
    @doc.fullPath if @isIndex() then '' else @path

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
    ajax
      url: @fileUrl()
      dataType: 'html'
      success: onSuccess
      error: onError
