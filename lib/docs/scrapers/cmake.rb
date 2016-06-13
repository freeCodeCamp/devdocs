module Docs
  class Cmake < UrlScraper
    self.name = 'CMake'
    self.slug = 'cmake'
    self.type = 'cmake'
    self.release = '3.5'
    self.base_url = 'https://cmake.org/cmake/help/v3.5/'

    options[:skip] = %w(
      release/index.html
      genindex.html
      search.html
    )

    options[:only_patterns] = [
     /manual/,
     /command/,
     /policy/,
     /prop_/,
     /variable/
    ]

    options[:container] = '.body'

    html_filters.push 'cmake/clean_html', 'cmake/entries'

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2016 Kitware, Inc.<br>
      Licensed under the BSD 3-clause License.
    HTML
  end
end
