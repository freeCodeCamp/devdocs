module Docs
  class Opentsdb < UrlScraper
    self.name = 'OpenTSDB'
    self.type = 'sphinx_simple'
    self.release = '2.4.1'
    self.base_url = 'https://opentsdb.net/docs/build/html/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://opentsdb.net/',
      code: 'https://github.com/OpenTSDB/opentsdb'
    }

    html_filters.push 'opentsdb/entries', 'opentsdb/clean_html'

    options[:skip] = %w(genindex.html search.html)

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 The OpenTSDB Authors<br>
      Licensed under the GNU LGPLv2.1+ and GPLv3+ licenses.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('OpenTSDB', 'opentsdb', opts)
    end
  end
end
