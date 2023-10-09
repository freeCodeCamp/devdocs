module Docs
  class Python < FileScraper
    self.type = 'python'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.python.org/',
      code: 'https://github.com/python/cpython'
    }

    options[:skip_patterns] = [/whatsnew/]
    options[:skip] = %w(
      library/2to3.html
      library/formatter.html
      library/intro.html
      library/undoc.html
      library/unittest.mock-examples.html
      library/sunau.html)

    options[:attribution] = <<-HTML
      &copy; 2001&ndash;2023 Python Software Foundation<br>
      Licensed under the PSF License.
    HTML

    version '3.12' do
      self.release = '3.12.0'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.11' do
      self.release = '3.11.5'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.10' do
      self.release = '3.10.13'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.9' do
      self.release = '3.9.14'
      self.base_url = 'https://docs.python.org/3.9/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.8' do
      self.release = '3.8.14'
      self.base_url = 'https://docs.python.org/3.8/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.7' do
      self.release = '3.7.14'
      self.base_url = 'https://docs.python.org/3.7/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.6' do
      self.release = '3.6.12'
      self.base_url = 'https://docs.python.org/3.6/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.5' do
      self.release = '3.5.9'
      self.base_url = 'https://docs.python.org/3.5/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '2.7' do
      self.release = '2.7.17'
      self.base_url = 'https://docs.python.org/2.7/'

      html_filters.push 'python/entries_v2', 'sphinx/clean_html', 'python/clean_html'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.python.org/', opts)
      doc.at_css('title').content.split(' ')[0]
    end
  end
end
