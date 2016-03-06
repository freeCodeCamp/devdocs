module Docs
  class Mocha < UrlScraper
    self.name = 'mocha'
    self.type = 'mocha'
    self.release = '2.4.5'
    self.base_url = 'https://mochajs.org/'
    self.links = {
      home: 'https://mochajs.org/',
      code: 'https://github.com/mochajs/mocha'
    }

    html_filters.push 'mocha/entries', 'mocha/clean_html', 'title'

    options[:container] = '#content'
    options[:title] = 'mocha'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2016 TJ Holowaychuk<br>
      Licensed under the MIT License.
    HTML
  end
end
