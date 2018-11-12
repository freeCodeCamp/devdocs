module Docs
  class Jest < Docusaurus
    self.release = '23.6.0'
    self.base_url = 'https://jestjs.io/docs/en/'
    self.root_path = 'getting-started'
    self.links = {
      home: 'https://jestjs.io/',
      code: 'https://github.com/facebook/jest'
    }

    html_filters.push 'jest/entries', 'jest/clean_html'

    options[:trailing_slash] = false
    options[:skip_patterns] = /\.html$/i

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
