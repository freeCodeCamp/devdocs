module Docs
  class Opentsdb < UrlScraper
    self.name = 'OpenTSDB'
    self.type = 'opentsdb'
    self.release = '2.1.0'
    self.base_url = 'http://opentsdb.net/docs/build/html/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://opentsdb.net/',
      code: 'https://github.com/OpenTSDB/opentsdb'
    }

    html_filters.push 'opentsdb/entries', 'opentsdb/clean_html'

    options[:skip] = %w(genindex.html search.html)

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2015 The OpenTSDB Authors<br>
      Licensed under the GNU LGPLv2.1+ and GPLv3+ licenses.
    HTML
  end
end
