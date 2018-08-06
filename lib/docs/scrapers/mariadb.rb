module Docs
  class Mariadb < UrlScraper
    self.name = 'MariaDB'
    self.type = 'mariadb'
    self.release = '10.3.8'
    self.base_url = 'http://kb-mirror.mariadb.com/kb/en/library/documentation/'
    self.links = {
      home: 'https://mariadb.com/',
      code: 'https://github.com/MariaDB/server'
    }

    html_filters.push 'mariadb/entries', 'mariadb/clean_html', 'title'

    options[:download_images] = false
    options[:root_title] = 'MariaDB'

    options[:attribution] = <<-HTML
      &copy; 2018 MariaDB<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License and the GNU Free Documentation License.
    HTML
  end
end
