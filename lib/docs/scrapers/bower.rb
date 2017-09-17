module Docs
  class Bower < UrlScraper
    self.name = 'Bower'
    self.type = 'bower'
    self.release = '1.8.2'
    self.base_url = 'https://bower.io/docs/'
    self.root_path = 'api'
    self.links = {
      home: 'https://bower.io/',
      code: 'https://github.com/bower/bower'
    }

    html_filters.push 'bower/clean_html', 'bower/entries'

    options[:trailing_slash] = false
    options[:skip] = %w(tools about)

    options[:attribution] = <<-HTML
      &copy; 2017 Bower contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
