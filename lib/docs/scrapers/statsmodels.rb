module Docs
  class Statsmodels < UrlScraper
    self.type = 'sphinx'
    self.release = '0.15.0'
    self.base_url = 'https://www.statsmodels.org/stable/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.statsmodels.org/',
      code: 'https://github.com/statsmodels/statsmodels/'
    }

    html_filters.push 'math', 'statsmodels/entries', 'statsmodels/clean_html', 'sphinx/clean_html'

    # pydata-sphinx-theme: keep the whole main column so that the breadcrumbs,
    # which sit outside the article, are available to EntriesFilter.
    options[:container] = 'main.bd-main'

    options[:skip] = %w(about.html search.html genindex.html py-modindex.html)
    options[:skip_patterns] = [/\Arelease/, /\Adev/, /\A_modules/, /\Adatasets/]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2018 Statsmodels Developers<br>
      &copy; 2006&ndash;2008 Scipy Developers<br>
      &copy; 2006 Jonathan E. Taylor<br>
      Licensed under the 3-clause BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('statsmodels', 'statsmodels', opts)
    end
  end
end
