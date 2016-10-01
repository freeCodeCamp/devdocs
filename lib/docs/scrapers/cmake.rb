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
      &copy; 2000&ndash;2016 Kitware, Inc.<br>
      &copy; 2000&ndash;2011 Insight Software Consortium<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '3.6' do
      self.release = '3.6.2'
      self.base_url = 'https://cmake.org/cmake/help/v3.6/'
    end

    version '3.5' do
      self.release = '3.5.2'
      self.base_url = 'https://cmake.org/cmake/help/v3.5/'
    end
  end
end
