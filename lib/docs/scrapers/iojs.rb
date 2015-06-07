module Docs
  class Iojs < UrlScraper
    self.name = 'io.js'
    self.slug = 'iojs'
    self.type = 'node'
    self.version = '2.2.1'
    self.base_url = 'https://iojs.org/api/'
    self.links = {
      home: 'https://iojs.org/en/index.html',
      code: 'https://github.com/iojs/io.js'
    }

    html_filters.push 'node/clean_html', 'node/entries', 'title'

    options[:title] = false
    options[:root_title] = 'io.js'
    options[:container] = '#apicontent'
    options[:skip] = %w(index.html all.html documentation.html synopsis.html)

    options[:attribution] = <<-HTML
      &copy; io.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
