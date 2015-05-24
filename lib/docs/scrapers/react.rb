module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'react'
    self.version = '0.13.3'
    self.base_url = 'http://facebook.github.io/react/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'http://facebook.github.io/react/',
      code: 'https://github.com/facebook/react'
    }

    html_filters.push 'react/entries', 'react/clean_html'

    options[:container] = '.documentationContent'

    options[:skip] = %w(
      videos.html
      complementary-tools.html
      examples.html
      conferences.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2015 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
