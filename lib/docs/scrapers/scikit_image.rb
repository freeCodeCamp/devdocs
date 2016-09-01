module Docs
  class ScikitImage < UrlScraper
    self.name = 'scikit-image'
    self.slug = 'scikit_image'
    self.type = 'sphinx'
    self.release = '0.12.2'
    self.base_url = 'http://scikit-image.org/docs/0.12.x/api/'
    self.root_path = 'api.html'

    self.links = {
      home: 'http://scikit-image.org/',
      code: 'https://github.com/scikit-image/scikit-image'
    }

    html_filters.push 'scikit_image/entries', 'scikit_image/clean_html', 'sphinx/clean_html'

    options[:container] = '.span9'

    options[:attribution] = <<-HTML
      &copy; 2011 the scikit-image development team<br>
      Licensed under the scikit-image License.
    HTML
  end
end
