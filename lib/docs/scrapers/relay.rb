module Docs
  class Relay < Docusaurus
    self.release = '1.7.0'
    self.base_url = 'https://facebook.github.io/relay/docs/en/'
    self.root_path = 'introduction-to-relay.html'
    self.links = {
      home: 'https://facebook.github.io/relay/',
      code: 'https://github.com/facebook/relay'
    }

    html_filters.push 'relay/entries', 'relay/clean_html'

    options[:skip] = %w(videos.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
