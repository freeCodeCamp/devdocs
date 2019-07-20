module Docs
  class Python < FileScraper
    self.type = 'python'
    self.root_path = 'library/index.html'
    self.links = {
      home: 'https://www.python.org/',
      code: 'https://github.com/python/cpython'
    }

    options[:only_patterns] = [/\Alibrary\//]

    options[:skip] = %w(
      library/2to3.html
      library/formatter.html
      library/index.html
      library/intro.html
      library/undoc.html
      library/unittest.mock-examples.html
      library/sunau.html)

    options[:attribution] = <<-HTML
      &copy; 2001&ndash;2018 Python Software Foundation<br>
      Licensed under the PSF License.
    HTML

    version '3.7' do # docs.python.org/3.7/download.html
      self.release = '3.7.0'
      self.base_url = 'https://docs.python.org/3.7/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.6' do # docs.python.org/3.6/download.html
      self.release = '3.6.6'
      self.base_url = 'https://docs.python.org/3.6/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.5' do # docs.python.org/3.5/download.html
      self.release = '3.5.3'
      self.base_url = 'https://docs.python.org/3.5/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '2.7' do # docs.python.org/2.7/download.html
      self.release = '2.7.13'
      self.base_url = 'https://docs.python.org/2.7/'

      html_filters.push 'python/entries_v2', 'sphinx/clean_html', 'python/clean_html'
    end
  end
end
