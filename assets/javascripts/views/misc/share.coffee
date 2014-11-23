#= require views/misc/notif

class app.views.Share extends app.views.Notif
  @defautOptions:
    autoHide: null

  init: ->
    @type = 'Share'
    @count = app.store.get('count') or 0
    app.store.set 'count', ++@count
    @show() if @count is 5
    return
