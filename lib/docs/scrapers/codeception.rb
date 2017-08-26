module Docs
  class Codeception < UrlScraper
    self.name = 'Codeception'
    self.type = 'codeception'
    self.release = '2.3.5'
    self.base_url = 'http://codeception.com/docs/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://codeception.com/',
      code: 'https://github.com/codeception/codeception'
    }

    html_filters.push 'codeception/entries', 'codeception/clean_html'

    options[:skip_patterns] = [/install/]

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 Michael Bodnarchuk and contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
