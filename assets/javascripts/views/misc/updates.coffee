#= require views/misc/notif

class app.views.Updates extends app.views.Notif
  @className += ' _notif-news'

  @defautOptions:
    autoHide: 30000

  init: ->
    @lastUpdateTime = @getLastUpdateTime()
    @updatedDocs = @getUpdatedDocs()
    @updatedDisabledDocs = @getUpdatedDisabledDocs()
    @show() if @updatedDocs.length > 0 or @updatedDisabledDocs.length > 0
    @markAllAsRead()
    return

  render: ->
    @html app.templates.notifUpdates(@updatedDocs, @updatedDisabledDocs)
    return

  getUpdatedDocs: ->
    return [] unless @lastUpdateTime
    doc for doc in app.docs.all() when doc.mtime > @lastUpdateTime

  getUpdatedDisabledDocs: ->
    return [] unless @lastUpdateTime
    doc for doc in app.disabledDocs.all() when doc.mtime > @lastUpdateTime and app.docs.findBy('slug_without_version', doc.slug_without_version)

  getLastUpdateTime: ->
    app.settings.get 'version'

  markAllAsRead: ->
    app.settings.set 'version', if app.config.env is 'production' then app.config.version else Math.floor(Date.now() / 1000)
    return
