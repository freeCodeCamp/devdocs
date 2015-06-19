module Docs
  class Webpack < UrlScraper
    self.name = 'Webpack'
    self.type = 'webpack'
    self.version = '1.9'
    self.base_url = 'https://webpack.github.io/docs/'
    self.root_path = 'index.html'

    html_filters.push 'webpack/entries', 'webpack/clean_html'


    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2015 Tobias Koppers<br>
      Licensed under the MIT License.
    HTML
  end
end
