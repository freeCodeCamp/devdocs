module Docs
  class Mariadb < UrlScraper
    self.name = 'MariaDB'
    self.type = 'mariadb'
    self.release = '10.4.8'
    self.base_url = 'https://mariadb.com/kb/en/'
    self.root_path = 'library/documentation/'
    self.links = {
      home: 'https://mariadb.com/',
      code: 'https://github.com/MariaDB/server'
    }

    html_filters.insert_before 'internal_urls', 'mariadb/erase_invalid_pages'
    html_filters.push 'mariadb/entries', 'mariadb/clean_html'

    options[:rate_limit] = 200
    options[:skip_patterns] = [
      /\+/,
      /\/ask\//,
      /-release-notes\//,
      /-changelog\//,
      /^documentation\//,
      /^mariadb-server-documentation\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2019 MariaDB<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License and the GNU Free Documentation License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://mariadb.com/downloads/', opts)
      doc.at_css('[data-version-id="mariadb_server-versions"] option').content.split('-')[0]
    end
  end
end
