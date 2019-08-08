module Docs
  class Cmake < UrlScraper
    self.name = 'CMake'
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://cmake.org/',
      code: 'https://cmake.org/gitweb?p=cmake.git;a=summary'
    }

    html_filters.push 'cmake/clean_html', 'sphinx/clean_html', 'cmake/entries', 'title'

    options[:container] = '.body'
    options[:title] = false
    options[:root_title] = 'CMake Reference Documentation'
    options[:skip] = %w(release/index.html genindex.html search.html)
    options[:skip_patterns] = [/\Agenerator/, /\Acpack_gen/, /\Ainclude/, /\Arelease/]

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2019 Kitware, Inc. and Contributors<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '3.15' do
      self.release = '3.15.2'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.14' do
      self.release = '3.14.6'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.13' do
      self.release = '3.13.5'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.12' do
      self.release = '3.12.4'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.11' do
      self.release = '3.11.4'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.10' do
      self.release = '3.10.3'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.9' do
      self.release = '3.9.6'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.8' do
      self.release = '3.8.2'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.7' do
      self.release = '3.7.2'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.6' do
      self.release = '3.6.3'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.5' do
      self.release = '3.5.2'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://cmake.org/documentation/', opts)
      link = doc.at_css('.entry-content ul > li > strong > a > big')
      link.content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
