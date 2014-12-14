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
      break if new Date(news[0]).getTime() <= time
      news

  getLastNewsTime: ->
    new Date(app.news[0][0]).getTime()

  getLastReadTime: ->
    app.store.get 'news'

  markAllAsRead: ->
    app.store.set 'news', @getLastNewsTime() + 1
    return
