// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require views/misc/notif

const Cls = (app.views.News = class News extends app.views.Notif {
  static initClass() {
    this.className += " _notif-news";

    this.defautOptions = { autoHide: 30000 };
  }

  init() {
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
    let time;
    if (!(time = this.getLastReadTime())) {
      return [];
    }

    return (() => {
      const result = [];
      for (var news of Array.from(app.news)) {
        if (new Date(news[0]).getTime() <= time) {
          break;
        }
        result.push(news);
      }
      return result;
    })();
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
});
Cls.initClass();
