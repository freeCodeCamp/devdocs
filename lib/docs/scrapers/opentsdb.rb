module Docs
  class Opentsdb < UrlScraper
    self.name = 'OpenTSDB'
    self.type = 'opentsdb'
    self.version = '2.1'
    self.base_url = 'http://opentsdb.net/docs/build/html/'
    self.root_path = 'index.html'

    html_filters.push 'opentsdb/entries', 'opentsdb/clean_html'


    options[:skip] = %w(genindex.html search.html)


    options[:attribution] = <<-HTML
      &copy; 2015 OpenTSDB
    HTML
  end
end
