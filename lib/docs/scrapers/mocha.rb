module Docs
  class Mocha < UrlScraper
    self.name = 'mocha'
    self.type = 'mocha'
    self.version = '2.3.3'
    self.base_url = 'http://mochajs.org/'
    self.links = {
      home: 'http://mochajs.org/',
      code: 'https://github.com/mochajs/mocha'
    }

    html_filters.push 'mocha/entries', 'mocha/clean_html', 'title'

    options[:container] = '#content'
    options[:title] = 'mocha'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2015 TJ Holowaychuk<br>
      Licensed under the MIT License.
    HTML
  end
end
