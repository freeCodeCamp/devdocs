module Docs
  class Requirejs < UrlScraper
    self.name = 'RequireJS'
    self.type = 'simple'
    self.release = '2.3.5'
    self.base_url = 'http://requirejs.org/docs/'
    self.links = {
      home: 'http://requirejs.org/',
      code: 'https://github.com/requirejs/requirejs'
    }
    self.root_path = 'api.html'
    self.initial_paths = %w(
      optimization.html
      jquery.html
      node.html
      dojo.html
      commonjs.html
      errors.html
      plugins.html
      why.html
      whyamd.html)

    html_filters.push 'requirejs/clean_html', 'requirejs/entries'

    options[:container] = '#content'
    options[:follow_links] = false
    options[:only] = self.initial_paths

    options[:attribution] = <<-HTML
      &copy; jQuery Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
