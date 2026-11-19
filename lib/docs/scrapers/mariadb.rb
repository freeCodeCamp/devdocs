module Docs
  class Mariadb < UrlScraper
    self.name = 'MariaDB'
    self.type = 'mariadb'
    self.release = '11.0.2'
    self.base_url = 'https://mariadb.com/kb/en/'
    self.root_path = 'documentation/'
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
      &copy; 2023 MariaDB<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License and the GNU Free Documentation License.
    HTML

    def get_latest_version(opts)
      api = 'https://downloads.mariadb.org/rest-api/mariadb/'
      major = fetch_json(api, opts)['major_releases'].find { |r| r['release_status'] == 'Stable' }
      fetch_json("#{api}#{major['release_id']}/", opts)['releases'].keys.max_by { |v| Gem::Version.new(v) }
    end

  end
end
