module Docs
  class Pony < UrlScraper
    self.type = 'pony'
    self.release = '0.25.0'
    self.base_url = 'https://stdlib.ponylang.io/'

    html_filters.push 'pony/container', 'pony/entries', 'pony/clean_html'
    options[:attribution] = "Me"
    options[:follow_links] = ->(filter) { filter.subpath !~ /src/ }
  end
end
