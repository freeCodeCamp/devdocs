// @ts-check

import { app } from "../../app/app.js";
import { news } from "../../templates/pages/news_tmpl.js";
import { notifNews } from "../../templates/notif_tmpl.js";
import { Notif } from "./notif.js";

/** The notification listing the changelog entries the user hasn't seen. */
export class News extends Notif {
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
    this.html(notifNews(this.unreadNews));
  }

  /**
   * @returns {Array<[string, ...string[]]>} The changelog entries published
   *   since the user last saw it.
   */
  getUnreadNews() {
    const time = this.getLastReadTime();
    if (!time) {
      return [];
    }

    const result = [];
    for (var entry of news) {
      if (new Date(entry[0]).getTime() <= time) {
        break;
      }
      result.push(entry);
    }
    return result;
  }

  /** @returns {number} When the newest entry was published, in milliseconds. */
  getLastNewsTime() {
    return new Date(news[0][0]).getTime();
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
