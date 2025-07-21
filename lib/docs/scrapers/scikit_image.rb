module Docs
  class ScikitImage < UrlScraper
    self.name = 'scikit-image'
    self.slug = 'scikit_image'
    self.type = 'sphinx'
    self.release = '0.25.0'
    v = self.release[/\d+\.\d+/]
    self.base_url = "https://scikit-image.org/docs/#{v}.x/"
    self.initial_paths = %w(/ /api/ /user_guide/)
    self.links = {
      home: 'https://scikit-image.org/',
      code: 'https://github.com/scikit-image/scikit-image'
    }

    html_filters.push 'scikit_image/entries', 'sphinx/clean_html'

    options[:container] = 'main article'
    options[:skip] = %w(api_changes.html)
    options[:only_patterns] = [/\Aapi/, /\Auser_guide/]

    options[:attribution] = <<-HTML
      &copy; 2019 the scikit-image team<br>
      Licensed under the BSD 3-clause License.
    HTML

    def get_latest_version(opts)
      tags = get_github_tags('scikit-image', 'scikit-image', opts)
      tags[0]['name'][1..-1]
    end
  end
end
