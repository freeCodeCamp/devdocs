module Docs
  class Redux < UrlScraper

    self.type = 'simple'
    self.release = '4.0.5'
    self.base_url = 'https://redux.js.org/api'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://redux.js.org/',
      code: 'https://github.com/reduxjs/redux/'
    }

    html_filters.push 'redux/clean_html', 'redux/entries'

    options[:container] = '.markdown'

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2020 Dan Abramov<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('redux', opts)
    end

  end
end
