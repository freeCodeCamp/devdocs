class app.views.Notice extends app.View
  @className: '_notice'

  constructor: (@type, @args...) -> super

  init: ->
    @activate()
    return

  activate: ->
    @show() if super
    return

  deactivate: ->
    @hide() if super
    return

  show: ->
    @addClass '_top' if @type is 'disabledDoc'
    @html @tmpl("#{@type}Notice", @args...)
    @prependTo $('._app')
    return

  hide: ->
    $.remove @el
    return
