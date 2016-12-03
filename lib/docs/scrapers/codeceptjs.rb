module Docs
  class Codeceptjs < UrlScraper
    self.name = 'CodeceptJS'
    self.type = 'codeceptjs'
    self.root_path = 'index.html'
    self.release = '0.4'
    self.base_url = 'http://codecept.io/'
    self.links = {
      home: 'http://codecept.io/',
      code: 'https://github.com/codeception/codeceptjs'
    }

    html_filters.push 'codeceptjs/clean_html', 'codeceptjs/entries', 'title'

    options[:root_title] = 'CodeceptJS'
    options[:title] = false
    options[:skip_links] = ->(filter) { !filter.initial_page? }
    options[:skip_patterns] = [/changelog/, /quickstart$/]

    options[:attribution] = <<-HTML
      &copy; 2015–2016 Michael Bodnarchuk and Contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
