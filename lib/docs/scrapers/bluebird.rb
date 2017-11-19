module Docs
  class Bluebird < UrlScraper
    self.type = 'bluebird'
    self.base_url = 'http://bluebirdjs.com'
    self.root_path = '/docs/api-reference.html'
    self.release = '3.5.0'
    self.links = {
      home: 'http://bluebirdjs.com/',
      code: 'https://github.com/petkaantonov/bluebird/'
    }

    html_filters.push 'bluebird/clean_html', 'bluebird/entries'

    options[:container] = 'body .post'

    options[:attribution] = <<-HTML
      &copy; Petka Antonov<br/>
      Licensed under the MIT License.
    HTML
  end
end
