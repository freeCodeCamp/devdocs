#= require views/misc/notif

class app.views.Updates extends app.views.Notif
  @className += ' _notif-news'

  @defautOptions:
    autoHide: 30000

  init: ->
    @updatedDocs = @getUpdatedDocs()
    @show() if @updatedDocs.length
    @markAllAsRead()
    return

  render: ->
    @html app.templates.notifUpdates(@updatedDocs)
    return

  getUpdatedDocs: ->
    return [] unless time = @getLastUpdateTime()
    doc for doc in app.docs.all() when doc.mtime > time

  getLastUpdateTime: ->
    app.settings.get 'version'

  markAllAsRead: ->
    app.settings.set 'version', if app.config.env is 'production' then app.config.version else Math.floor(Date.now() / 1000)
    return
