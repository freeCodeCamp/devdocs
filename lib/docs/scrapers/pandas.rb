module Docs
  class Pandas < UrlScraper
    self.name = 'pandas'
    self.type = 'sphinx'
    self.root_path = 'api.html'
    self.links = {
      home: 'http://pandas.pydata.org/',
      code: 'https://github.com/pydata/pandas'
    }

    html_filters.push 'pandas/entries', 'pandas/clean_html', 'sphinx/clean_html'

    # Cannot take only the body, as the sidebar gives info about the type.
    options[:container] = '.document'

    # Using the above container, leads to tons of anchors. Only keep the generated/ pages.
    options[:only_patterns] = [/\Agenerated\//]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2014, the pandas development team.<br>
      Licensed under the BSD license.
    HTML

    version '0.18' do
      self.release = '0.18.1'
      self.base_url = "http://pandas.pydata.org/pandas-docs/version/#{self.release}/"
    end
  end
end
