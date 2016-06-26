module Docs
  class Matplotlib < FileScraper
    self.name = 'Matplotlib'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.release = "1.5.1"
    self.links = {
      home: 'http://matplotlib.org/',
      code: 'https://github.com/matplotlib/matplotlib'
    }

    html_filters.push 'matplotlib/entries', 'matplotlib/clean_html'

    options[:container] = '.body'

    options[:attribution] = <<-HTML
      &copy; Matplotlib Development Team <br>
      Licensed under the BSD License.
    HTML

    self.dir = '~/workspace/tmp/matplotlib/matplotlib.github.com-master/1.5.1/api/'
    # self.base_url = 'http://matplotlib.org/api/'
  end
end
