module Docs
  class Pony < UrlScraper
    self.type = 'pony'
    self.release = '0.25.0'
    self.base_url = 'https://stdlib.ponylang.io/'

    html_filters.push 'pony/container', 'pony/clean_html', 'pony/entries'
    options[:attribution] = "Me"
    options[:follow_links] = ->(filter) { filter.subpath !~ /src/ }
  end
end
