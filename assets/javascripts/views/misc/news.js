// @ts-check

//= require views/misc/notif

/** The notification listing the changelog entries the user hasn't seen. */
class News extends Notif {
  static className = "_notif _notif-news";

  static defaultOptions = { autoHide: 30000 };

  /** @inheritdoc */
  init0() {
    this.unreadNews = this.getUnreadNews();
    if (this.unreadNews.length) {
      this.show();
    }
    this.markAllAsRead();
  }

  /** @inheritdoc */
  render() {
    this.html(app.templates.notifNews(this.unreadNews));
  }

  /** @returns {Entry[]} Entries published since the user last saw the changelog. */
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

  /** @returns {number} When the newest entry was published, in milliseconds. */
  getLastNewsTime() {
    return new Date(app.news[0][0]).getTime();
  }

  /** @returns {number} When the user last saw the changelog, in milliseconds. */
  getLastReadTime() {
    return app.settings.get("news");
  }

  /** Records that the user has seen every entry. */
  markAllAsRead() {
    app.settings.set("news", this.getLastNewsTime());
  }
}

// Registered on `app` so that the rest of the code can reach it; declared at
// the top level so that it can be named in a type.
app.views.News = News;
