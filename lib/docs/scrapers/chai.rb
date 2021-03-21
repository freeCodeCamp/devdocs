module Docs
  class Chai < UrlScraper
    self.name = 'Chai'
    self.type = 'simple'
    self.release = '4.3.4'
    self.base_url = 'https://www.chaijs.com'
    self.root_path = '/api/'
    self.initial_paths = %w(/guide/installation/)
    self.links = {
      home: 'https://www.chaijs.com/',
      code: 'https://github.com/chaijs/chai'
    }

    html_filters.push 'chai/entries', 'chai/clean_html'

    options[:container] = '#content'
    options[:trailing_slash] = true

    options[:only_patterns] = [/\A\/guide/, /\A\/api/]
    options[:skip] = %w(/api/test/ /guide/ /guide/resources/)

    options[:attribution] = <<-HTML
      &copy; 2017 Chai.js Assertion Library<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('chai', opts)
    end
  end
end
