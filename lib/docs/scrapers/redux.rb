module Docs
  class Redux < UrlScraper
    self.type = 'simple'
    self.release = '3.7.2'
    self.base_url = 'http://redux.js.org/docs/'
    self.links = {
      home: 'http://redux.js.org/',
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
  end
end
