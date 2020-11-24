module Docs
  class Jasmine < UrlScraper
    self.type = 'simple'
    self.release = '3.6.0'
    self.base_url = 'https://jasmine.github.io/api/3.6/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://jasmine.github.io/',
      code: 'https://github.com/jasmine/jasmine'
    }

    html_filters.push 'jasmine/clean_html', 'jasmine/entries'

    options[:container] = '.main-content'

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2019 Pivotal Labs<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('jasmine', 'jasmine', opts)
    end
  end
end
