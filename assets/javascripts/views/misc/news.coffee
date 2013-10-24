#= require views/misc/notif

class app.views.News extends app.views.Notif
  @className += ' _notif-news'

  @defautOptions:
    autoHide: null

  init: ->
    @unreadNews = @getUnreadNews()
    @show() if @unreadNews.length
    @markAllAsRead()
    return

  render: ->
    @html app.templates.notifNews(@unreadNews)
    return

  getUnreadNews: ->
    return [] unless time = @getLastReadTime()

    for news in app.news
      break if news[0] <= time
      news

  getLastNewsTime: ->
    app.news[0][0]

  getLastReadTime: ->
    app.store.get 'news'

  markAllAsRead: ->
    app.store.set 'news', @getLastNewsTime()
    return
