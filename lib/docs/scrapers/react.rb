module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'react'
    self.version = '0.12.2'
    self.base_url = 'http://facebook.github.io/react/docs/'
    self.root_path = 'getting-started.html'

    html_filters.push 'react/entries', 'react/clean_html'

    options[:container] = '.documentationContent'

    options[:skip] = %w(
      videos.html
      complementary-tools.html
      examples.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2014 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
