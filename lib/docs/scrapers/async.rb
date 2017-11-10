module Docs
  class Async < UrlScraper
    self.type = 'async'
    self.release = '2.6.0'
    self.base_url = 'https://caolan.github.io/async/'
    self.root_path = 'docs.html'
    self.links = {
      home: 'https://caolan.github.io/async/',
      code: 'https://github.com/caolan/async'
    }

    html_filters.push 'async/entries', 'async/clean_html'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2017 Caolan McMahon<br>
      Licensed under the MIT License.
    HTML
  end
end
