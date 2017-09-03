module Docs
  class Mocha < UrlScraper
    self.type = 'mocha'
    self.release = '3.2.0'
    self.base_url = 'https://mochajs.org/'
    self.links = {
      home: 'https://mochajs.org/',
      code: 'https://github.com/mochajs/mocha'
    }

    html_filters.push 'mocha/clean_html', 'mocha/entries', 'title'

    options[:container] = '#content'
    options[:title] = 'mocha'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2016 JS Foundation and contributors<br>
      Licensed under the Creative Commons Attribution 4.0 International License.
    HTML
  end
end
