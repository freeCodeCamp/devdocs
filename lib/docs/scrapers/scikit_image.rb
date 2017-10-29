module Docs
  class ScikitImage < UrlScraper
    self.name = 'scikit-image'
    self.slug = 'scikit_image'
    self.type = 'sphinx'
    self.release = '0.13.1'
    self.base_url = 'http://scikit-image.org/docs/0.13.x/'
    self.links = {
      home: 'http://scikit-image.org/',
      code: 'https://github.com/scikit-image/scikit-image'
    }

    html_filters.push 'scikit_image/entries', 'sphinx/clean_html'

    options[:container] = '.span9'
    options[:skip] = %w(api_changes.html)
    options[:only_patterns] = [/\Aapi/, /\Auser_guide/]

    options[:attribution] = <<-HTML
      &copy; 2011 the scikit-image team<br>
      Licensed under the BSD 3-clause License.
    HTML
  end
end
