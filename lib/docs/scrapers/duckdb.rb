module Docs
  class Duckdb < UrlScraper
    self.name = 'DuckDB'
    self.type = 'duckdb'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://duckdb.org/',
      code: 'https://github.com/duckdb/duckdb'
    }

    # https://duckdb.org/docs/guides/offline-copy.html
    # curl -O https://duckdb.org/duckdb-docs.zip; bsdtar xf duckdb-docs.zip; cd duckdb-docs; python -m http.server
    self.release = '1.1.3'
    self.base_url = 'http://localhost:8000/docs/'

    html_filters.push 'duckdb/entries', 'duckdb/clean_html'
    text_filters.replace 'attribution', 'duckdb/attribution'

    options[:container] = '.documentation'
    
    options[:skip_patterns] = [
      /installation/,
      /archive/,
      /reference/,
    ]

    options[:skip] = %w(
      docs/archive/
      docs/installation/
      docs/api/
    )

    options[:attribution] = <<-HTML
      &copy; Copyright 2018&ndash;2024 Stichting DuckDB Foundation<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_github_tags('duckdb', 'duckdb', opts)[0]['name']
    end
  end
end
