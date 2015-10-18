module Docs
  class Bower < UrlScraper
    self.name = 'Bower'
    self.type = 'bower'
    self.version = '1.6.3'
    self.base_url = 'http://bower.io/docs/'
    self.root_path = 'api'
    self.links = {
      home: 'http://bower.io/',
      code: 'https://github.com/bower/bower'
    }

    html_filters.push 'bower/clean_html', 'bower/entries'

    options[:trailing_slash] = false
    options[:skip] = %w(tools about)

    options[:attribution] = <<-HTML
      &copy; 2015 Bower contributors<br>
      Licensed under the Creative Commons Attribution License.
    HTML
  end
end
