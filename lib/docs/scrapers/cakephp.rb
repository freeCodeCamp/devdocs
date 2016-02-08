module Docs
  class Cakephp < FileScraper
    self.name = 'CakePHP'
    self.type = 'cakephp'
    self.version = '3.1'
    self.dir = ''
    self.base_url = "http://api.cakephp.org/#{version}/"
    self.root_path = 'index.html'
    self.links = {
      home: 'http://cakephp.org/',
      code: 'https://github.com/cakephp/cakephp'
    }

    html_filters.push 'cakephp/clean_html', 'cakephp/entries'

    options[:container] = '#right.columns.nine'

    # CakePHP docs include full source code. Ignore it.
    options[:skip_patterns] = [/\Asource-/]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2015 The Cake Software Foundation, Inc.<br>
      Licensed under the MIT License.
    HTML
  end
end
