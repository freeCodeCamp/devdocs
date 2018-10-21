module Docs
  class Chai < UrlScraper
    self.name = 'Chai'
    self.type = 'simple'
    self.release = '4.1.0'
    self.base_url = 'http://chaijs.com'
    self.root_path = '/api/'
    self.initial_paths = %w(/guide/installation/)
    self.links = {
      home: 'http://chaijs.com/',
      code: 'https://github.com/chaijs/chai'
    }

    html_filters.push 'chai/entries', 'chai/clean_html'

    options[:container] = '#content'
    options[:trailing_slash] = true

    options[:only_patterns] = [/\A\/guide/, /\A\/api/]
    options[:skip] = %w(/api/test/ /guide/ /guide/resources/)

    options[:attribution] = <<-HTML
      &copy; 2016 Chai.js Assertion Library<br>
      Licensed under the MIT License.
    HTML
  end
end
