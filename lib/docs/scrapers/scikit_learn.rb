module Docs
  class ScikitLearn < UrlScraper
    self.name = 'scikit-learn'
    self.slug = 'scikit_learn'
    self.type = 'sphinx'
    self.release = '0.17.1'
    self.base_url = "http://scikit-learn.org/0.17/"
    self.root_path = 'documentation.html'
    self.initial_paths = %w(
      user_guide.html
      supervised_learning.html
      unsupervised_learning.html
      model_selection.html
      data_transforms.html)

    self.links = {
      home: 'http://scikit-learn.org/',
      code: 'https://github.com/scikit-learn/scikit-learn'
    }

    html_filters.push 'scikit_learn/entries', 'sphinx/clean_html'

    options[:container] = '.body'

    options[:root_title] = self.name

    options[:only] = self.initial_paths
    options[:only_patterns] = [/\Amodules/, /\Adatasets/]

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2016 The scikit-learn deveopers<br>
      Licensed under the 3-clause BSD License.
    HTML

  end
end
