module Docs
  class ScikitLearn < UrlScraper
    self.name = 'scikit-learn'
    self.slug = 'scikit_learn'
    self.type = 'sphinx'
    self.release = '0.20.0'
    self.base_url = 'http://scikit-learn.org/stable/'
    self.root_path = 'documentation.html'
    self.force_gzip = true
    self.links = {
      home: 'http://scikit-learn.org/',
      code: 'https://github.com/scikit-learn/scikit-learn'
    }

    html_filters.push 'scikit_learn/entries', 'scikit_learn/clean_html', 'sphinx/clean_html'

    options[:container] = ->(filter) { filter.root_page? ? '.container-index' : '.body' }
    options[:skip] = %w(tutorial/statistical_inference/finding_help.html)
    options[:only_patterns] = [/\Amodules/, /\Adatasets/, /\Atutorial/, /\Aauto_examples/]
    options[:skip_patterns] = [/\Adatasets\/(?!index)/]
    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2018 The scikit-learn developers<br>
      Licensed under the 3-clause BSD License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://scikit-learn.org/stable/documentation.html', opts)
      doc.at_css('.body h1').content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
