module Docs
  class Duckdb < UrlScraper
    self.name = 'DuckDB'
    self.type = 'duckdb'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://duckdb.org/',
      code: 'https://github.com/duckdb/duckdb'
    }

    html_filters.push 'duckdb/entries', 'duckdb/clean_html'

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

    version '1.1' do
      self.release = '1.1.x'
      self.base_url = 'http://localhost:8000/docs/'
    end

    # version '1.0' do
    #     self.release = '1.0.x'
    #     self.base_url = "https://duckdb.org/docs/archive/#{self.version}/"

    #     html_filters.push 'duckdb/clean_html'
    # end

    # version '0.9' do
    #     self.release = '0.9.x'
    #     self.base_url = "https://duckdb.org/docs/archive/#{self.version}/"

    #     html_filters.push 'duckdb/clean_html'
    # end

    # version '0.8' do
    #     self.release = '0.8.x'
    #     self.base_url = "https://duckdb.org/docs/archive/#{self.version}/"

    #     html_filters.push 'duckdb/clean_html'
    # end

    # version '0.7' do
    #     self.release = '0.7.x'
    #     self.base_url = "https://duckdb.org/docs/archive/#{self.version}/"

    #     html_filters.push 'duckdb/clean_html'
    # end

    def get_latest_version(opts)
      get_github_tags('duckdb', 'duckdb', opts)
    end
  end
end
