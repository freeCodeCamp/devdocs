module Docs
  class Redux < UrlScraper
    self.type = 'simple'
    self.release = '4.0.4'
    self.base_url = 'https://redux.js.org/docs/'
    self.links = {
      home: 'https://redux.js.org/',
      code: 'https://github.com/reactjs/redux/'
    }

    html_filters.push 'redux/entries', 'redux/clean_html'

    options[:skip] = %w(Feedback.html)

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2017 Dan Abramov<br>
      Licensed under the MIT License.
    HTML

    stub '' do
      request_one('http://redux.js.org/index.html').body
    end

    def get_latest_version(opts)
      get_npm_version('redux', opts)
    end
  end
end
