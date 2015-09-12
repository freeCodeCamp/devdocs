module Docs
  class Node < UrlScraper
    self.name = 'Node.js'
    self.slug = 'node'
    self.type = 'node'
    self.version = '4.0.0'
    self.base_url = 'https://nodejs.org/api/'
    self.links = {
      home: 'https://nodejs.org/',
      code: 'https://github.com/joyent/node'
    }

    html_filters.push 'node/clean_html', 'node/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Node.js'
    options[:container] = '#apicontent'
    options[:skip] = %w(index.html all.html documentation.html synopsis.html)

    options[:attribution] = <<-HTML
      &copy; Joyent, Inc. and other Node contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
