module Docs
  class Cmake < UrlScraper
    self.name = 'CMake'
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://cmake.org/',
      code: 'https://gitlab.kitware.com/cmake/cmake/'
    }

    html_filters.push 'cmake/clean_html', 'sphinx/clean_html', 'cmake/entries', 'title'

    options[:container] = '.body'
    options[:title] = false
    options[:root_title] = 'CMake Reference Documentation'
    options[:skip] = %w(release/index.html genindex.html search.html)
    options[:skip_patterns] = [/\Agenerator/, /\Acpack_gen/, /\Ainclude/, /\Arelease/, /tutorial\/(\w*%20)+/]

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2023 Kitware, Inc. and Contributors<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '3.26' do
      self.release = '3.26'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.25' do
      self.release = '3.25'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.24' do
      self.release = '3.24'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.23' do
      self.release = '3.23'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.22' do
      self.release = '3.22'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.21' do
      self.release = '3.21'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.20' do
      self.release = '3.20'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.19' do
      self.release = '3.19.0'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.18' do
      self.release = '3.18.4'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.17' do
      self.release = '3.17.5'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.16' do
      self.release = '3.16.9'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.15' do
      self.release = '3.15.7'
      self.base_url = "https://cmake.org/cmake/help/v#{self.version}/"
    end

    version '3.14' do
      self.release = '3.14.7'
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
      tags = get_gitlab_tags('gitlab.kitware.com', 'cmake', 'cmake', opts)
      tags[0]['name'][1..]
    end
  end
end
