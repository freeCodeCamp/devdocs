module Docs
  class Jasmine < UrlScraper
    self.type = 'jasmine'
    self.release = '2.6.4'
    self.base_url = 'https://jasmine.github.io/api/2.6/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://jasmine.github.io/',
      code: 'https://github.com/jasmine/jasmine'
    }

    html_filters.push 'jasmine/clean_html', 'jasmine/entries'

    options[:container] = '.main-content'

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2017 Pivotal Labs<br>
      Licensed under the MIT License.
    HTML
  end
end
