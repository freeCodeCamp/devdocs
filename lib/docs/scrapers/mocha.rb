module Docs
  class Mocha < UrlScraper
    self.type = 'mocha'
    self.release = '2.5.3'
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
      &copy; Mocha contributors<br>
      Licensed under the Creative Commons Attribution 4.0 International License.
    HTML
  end
end
