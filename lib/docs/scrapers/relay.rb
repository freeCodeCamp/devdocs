module Docs
  class Relay < UrlScraper
    self.type = 'simple'
    self.release = '1.4.1'
    self.base_url = 'https://facebook.github.io/relay/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/relay/',
      code: 'https://github.com/facebook/relay'
    }

    html_filters.push 'relay/entries', 'relay/clean_html'

    options[:container] = '.documentationContent'
    options[:skip] = %w(videos.html graphql-further-reading.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
