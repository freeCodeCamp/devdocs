module Docs
  class Jest < UrlScraper
    self.type = 'jest'
    self.release = '22.3.0'
    self.base_url = 'https://facebook.github.io/jest/docs/en/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/jest/',
      code: 'https://github.com/facebook/jest'
    }

    html_filters.push 'jest/entries', 'jest/clean_html'

    options[:container] = '.docMainWrapper'

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
