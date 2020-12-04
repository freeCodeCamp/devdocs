module Docs
  class Redux < UrlScraper

    self.type = 'simple'
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

    version do
      self.release = '4.0.5'
    end

    version '3' do
      self.release = '3.7.2'
    end

    def get_latest_version(opts)
      get_npm_version('redux', opts)
    end

  end
end
