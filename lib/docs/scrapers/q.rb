module Docs
  class Q < UrlScraper
    self.name = 'Q'
    self.slug = 'Q'
    self.type = 'Q'
    self.version = '1.4.1'
    self.base_url = "https://github.com/kriskowal/q/wiki/API-Reference"
    self.links = {
      home: 'https://github.com/kriskowal/q/',
      code: 'https://github.com/kriskowal/q/'
    }

    html_filters.push 'q/clean_html', 'q/entries', 'title'

    options[:title] = 'Q'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
        Licensed under the MIT License.
    HTML
  end
end
