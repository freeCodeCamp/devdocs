//= require views/misc/notif

app.views.News = class News extends app.views.Notif {
  static className = "_notif _notif-news";

  static defaultOptions = { autoHide: 30000 };

  init0() {
    this.unreadNews = this.getUnreadNews();
    if (this.unreadNews.length) {
      this.show();
    }
    this.markAllAsRead();
  }

  render() {
    this.html(app.templates.notifNews(this.unreadNews));
  }

  getUnreadNews() {
    const time = this.getLastReadTime();
    if (!time) {
      return [];
    }

    const result = [];
    for (var news of app.news) {
      if (new Date(news[0]).getTime() <= time) {
        break;
      }
      result.push(news);
    }
    return result;
  }

  getLastNewsTime() {
    return new Date(app.news[0][0]).getTime();
  }

  getLastReadTime() {
    return app.settings.get("news");
  }

  markAllAsRead() {
    app.settings.set("news", this.getLastNewsTime());
  }
};
