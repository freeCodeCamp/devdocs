module Docs
  class Phpunit < UrlScraper
    self.name = 'PHPUnit'
    self.type = 'phpunit'
    self.version = '4.7'
    self.base_url = "https://phpunit.de/manual/#{version}/en/"
    self.root_path = 'index.html'
    self.links = {
      home: 'https://phpunit.de/',
      code: 'https://github.com/sebastianbergmann/phpunit'
    }

    html_filters.push 'phpunit/clean_html', 'phpunit/entries', 'title'

    options[:root_title] = 'PHPUnit'
    options[:title] = false

    options[:skip] = %w(
      appendixes.index.html
      appendixes.bibliography.html
      appendixes.copyright.html)

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2015 Sebastian Bergmann<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML
  end
end
