module Docs
  class Docusaurus < UrlScraper
    self.abstract = true
    self.type = 'simple'

    html_filters.push 'docusaurus/clean_html', 'docusaurus/entries'
  end
end
