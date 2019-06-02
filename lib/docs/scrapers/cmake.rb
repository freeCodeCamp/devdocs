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
    options[:skip_patterns] = [/\Agenerator/, /\Ainclude/, /\Arelease/]

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2018 Kitware, Inc. and Contributors<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '3.12' do
      self.release = '3.12.1'
      self.base_url = 'https://cmake.org/cmake/help/v3.12/'
    end

    version '3.11' do
      self.release = '3.11.4'
      self.base_url = 'https://cmake.org/cmake/help/v3.11/'
    end

    version '3.10' do
      self.release = '3.10.3'
      self.base_url = 'https://cmake.org/cmake/help/v3.10/'
    end

    version '3.9' do
      self.release = '3.9.6'
      self.base_url = 'https://cmake.org/cmake/help/v3.9/'
    end

    version '3.8' do
      self.release = '3.8.2'
      self.base_url = 'https://cmake.org/cmake/help/v3.8/'
    end

    version '3.7' do
      self.release = '3.7.2'
      self.base_url = 'https://cmake.org/cmake/help/v3.7/'
    end

    version '3.6' do
      self.release = '3.6.3'
      self.base_url = 'https://cmake.org/cmake/help/v3.6/'
    end

    version '3.5' do
      self.release = '3.5.2'
      self.base_url = 'https://cmake.org/cmake/help/v3.5/'
    end
  end
end
