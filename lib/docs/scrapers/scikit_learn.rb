module Docs
  class ScikitLearn < UrlScraper
    self.name = 'scikit-learn'
    self.slug = 'scikit_learn'
    self.type = 'sphinx'
    self.release = '1.1.3'
    self.base_url = "https://scikit-learn.org/1.1/"
    self.root_path = 'index.html'
    self.force_gzip = true
    self.links = {
      home: 'https://scikit-learn.org/',
      code: 'https://github.com/scikit-learn/scikit-learn'
    }

    html_filters.push 'scikit_learn/entries', 'scikit_learn/clean_html', 'sphinx/clean_html', 'title'

    options[:container] = ->(filter) { filter.root_page? ? 'body > .container' : '#sk-page-content-wrapper > .body' }
    options[:skip] = %w(modules/generated/sklearn.experimental.enable_iterative_imputer.html
                        modules/generated/sklearn.experimental.enable_hist_gradient_boosting.html)
    options[:only_patterns] = [/\Amodules/, /\Adatasets/, /\Atutorial/, /\Aauto_examples/]
    options[:skip_patterns] = [/\Adatasets\/(?!index)/]
    options[:title] = false
    options[:root_title] = 'scikit-learn'
    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2022 The scikit-learn developers<br>
      Licensed under the 3-clause BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('scikit-learn', 'scikit-learn', opts)
    end
  end
end
