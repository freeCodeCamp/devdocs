module Docs
  class Pandas < UrlScraper
    self.name = 'pandas'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://pandas.pydata.org/',
      code: 'https://github.com/pydata/pandas'
    }

    html_filters.push 'pandas/entries', 'pandas/clean_html', 'sphinx/clean_html'

    # Cannot take only the body, as the sidebar gives info about the type.
    options[:container] = '.document'

    options[:skip] = %w(internals.html release.html contributing.html whatsnew.html)
    options[:skip_patterns] = [/whatsnew\//]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2012, AQR Capital Management, LLC, Lambda Foundry, Inc. and PyData Development Team<br>
      Licensed under the 3-clause BSD License.
    HTML

    version '0.25' do
      self.release = '0.25.0'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.24' do
      self.release = '0.24.2'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.23' do
      self.release = '0.23.4'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.22' do
      self.release = '0.22.0'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.21' do
      self.release = '0.21.1'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.20' do
      self.release = '0.20.3'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.19' do
      self.release = '0.19.2'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.18' do
      self.release = '0.18.1'
      self.base_url = "https://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('http://pandas.pydata.org/pandas-docs/stable/', opts)
      label = doc.at_css('.body > .section > p').content
      label.scan(/Version: ([0-9.]+)/)[0][0]
    end
  end
end
