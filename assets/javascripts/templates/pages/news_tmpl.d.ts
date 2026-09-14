/** The changelog templates and data, rendered by news_tmpl.js.erb from news.json. */
export const newsPage: () => string;
export const newsList: (
  news: Array<[string, ...string[]]>,
  options?: { years?: boolean },
) => string;
export const news: Array<[string, ...string[]]>;
