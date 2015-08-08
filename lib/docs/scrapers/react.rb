module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'react'
    self.version = '0.13.3'
    self.base_url = 'https://facebook.github.io/react/'
    self.root_path = 'docs/getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/react/',
      code: 'https://github.com/facebook/react'
    }

    html_filters.push 'react/entries', 'react/clean_html'

    options[:container] = '.documentationContent'
    options[:only_patterns] = [/\Adocs\//, /\Atips\//]
    options[:skip] = %w(
      docs/
      docs/videos.html
      docs/complementary-tools.html
      docs/examples.html
      docs/conferences.html
      tips/introduction.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2015 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
