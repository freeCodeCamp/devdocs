/** The changelog templates, rendered by news_tmpl.js.erb from news.json. */
export const newsPage: () => string;
export const newsList: (
  news: Array<[string, ...string[]]>,
  options?: { years?: boolean },
) => string;
