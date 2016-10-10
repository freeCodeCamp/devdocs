module Docs
  class Statsmodels < UrlScraper
    self.type = 'sphinx'
    self.release = '0.6.1'
    self.base_url = 'http://statsmodels.sourceforge.net/stable/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://statsmodels.sourceforge.net/',
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

  end
end
