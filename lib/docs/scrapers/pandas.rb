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

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2012 Lambda Foundry, Inc. and PyData Development Team<br>
      &copy; 2008&ndash;2011 AQR Capital Management, LLC<br>
      &copy; 2008&ndash;2014 the pandas development team<br>
      Licensed under the 3-clause BSD License.
    HTML

    version '0.19' do
      self.release = '0.19.2'
      self.base_url = "http://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end

    version '0.18' do
      self.release = '0.18.1'
      self.base_url = "http://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end
  end
end
