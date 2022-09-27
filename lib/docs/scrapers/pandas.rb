module Docs
  class Pandas < FileScraper
    self.name = 'pandas'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://pandas.pydata.org/',
      code: 'https://github.com/pydata/pandas'
    }

    options[:skip] = %w(internals.html release.html contributing.html whatsnew.html)
    options[:skip_patterns] = [/whatsnew\//]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2022, AQR Capital Management, LLC, Lambda Foundry, Inc. and PyData Development Team<br>
      Licensed under the 3-clause BSD License.
    HTML

    version '1' do
      self.release = '1.5.0'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/clean_html', 'pandas/entries'

      options[:container] = 'main section'

      options[:skip_patterns] = [
        /development/,
        /getting_started/,
        /whatsnew/
      ]

      options[:skip] = [
        'panel.html',
        'pandas.pdf',
        'pandas.zip',
        'ecosystem.html'
      ]

    end

    version '0.25' do
      self.release = '0.25.0'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    version '0.24' do
      self.release = '0.24.2'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'
      options[:container] = '.document'

    end

    version '0.23' do
      self.release = '0.23.4'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'
      options[:container] = '.document'

    end

    version '0.22' do
      self.release = '0.22.0'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    version '0.21' do
      self.release = '0.21.1'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    version '0.20' do
      self.release = '0.20.3'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    version '0.19' do
      self.release = '0.19.2'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    version '0.18' do
      self.release = '0.18.1'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"

      html_filters.push 'pandas/entries_old', 'pandas/clean_html_old', 'sphinx/clean_html'

      options[:container] = '.document'

    end

    def get_latest_version(opts)
      get_latest_github_release('pandas-dev', 'pandas', opts)
    end
  end
end
