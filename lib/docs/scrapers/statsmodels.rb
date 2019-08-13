module Docs
  class Statsmodels < UrlScraper
    self.type = 'sphinx'
    self.release = '0.9.0'
    self.base_url = 'http://www.statsmodels.org/stable/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://www.statsmodels.org/',
      code: 'https://github.com/statsmodels/statsmodels/'
    }

    html_filters.push 'statsmodels/entries', 'statsmodels/clean_html', 'sphinx/clean_html'

    options[:skip] = %w(about.html search.html genindex.html)
    options[:skip_patterns] = [/\Arelease/, /\Adev/, /\A_modules/, /\Adatasets/]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2012 Statsmodels Developers<br>
      &copy; 2006&ndash;2008 Scipy Developers<br>
      &copy; 2006 Jonathan E. Taylor<br>
      Licensed under the 3-clause BSD License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('http://www.statsmodels.org/stable/', opts)
      doc.at_css('.sphinxsidebarwrapper h3 + p > b').content[1..-1]
    end
  end
end
