module Docs
  class Polars < UrlScraper
    self.name = 'Polars'
    self.type = 'sphinx'
    self.release = '1.41.0'
    self.base_url = 'https://docs.pola.rs/api/python/stable/reference/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://pola.rs/',
      code: 'https://github.com/pola-rs/polars'
    }

    html_filters.push 'polars/entries', 'sphinx/clean_html', 'polars/clean_html'

    # pydata-sphinx-theme keeps the page content in the article body.
    options[:container] = 'article.bd-article'

    options[:skip_patterns] = [/_changelog/, /whatsnew/]

    # https://github.com/pola-rs/polars/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2020 Ritchie Vink<br>
      &copy; 2022 Polars contributors<br>
      Licensed under the MIT License.
    HTML

    # Polars tags both Rust (rs-*) and Python (py-*) releases in the same repo.
    # The tags API only lists recent Rust ones, but the latest GitHub release is
    # always the Python one, so use that and drop the py- prefix.
    def get_latest_version(opts)
      get_latest_github_release('pola-rs', 'polars', opts).sub(/\Apy-/, '')
    end
  end
end
