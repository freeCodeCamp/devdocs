module Docs
  class Github < UrlScraper
    self.abstract = true
    self.type = 'github'

    html_filters.push 'github/clean_html'
  end
end
