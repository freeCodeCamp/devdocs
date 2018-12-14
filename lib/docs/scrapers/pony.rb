module Docs
  class Pony < UrlScraper
    self.type = 'pony'
    self.release = '0.25.0'
    self.base_url = 'https://stdlib.ponylang.io/'

    html_filters.push 'pony/container', 'pony/entries'

    options[:attribution] = <<-HTML
      &copy; 2018 Pony Developers
    HTML

    options[:trailing_slash] = false
    options[:skip_patterns] = [/src/]
  end
end
