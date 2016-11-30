module Docs
  class Codeception < UrlScraper
    self.name = 'Codeception'
    self.type = 'codeception'
    self.root_path = 'index.html'
    self.release = '2.2'
    self.base_url = 'http://codeception.com/docs/'
    self.links = {
      home: 'http://codeception.com/',
      code: 'https://github.com/codeception/codeception'
    }

    html_filters.push 'codeception/clean_html', 'codeception/entries', 'title'

    options[:root_title] = 'Codeception'
    options[:title] = false
    options[:skip_patterns] = [/install/]

    options[:attribution] = <<-HTML
      &copy; 2011–2016 Michael Bodnarchuk and Contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
