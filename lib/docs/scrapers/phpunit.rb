module Docs
  class Phpunit < UrlScraper
    self.name = 'PHPUnit'
    self.type = 'phpunit'
    self.version = '4.4'
    self.base_url = "https://phpunit.de/manual/#{version}/en/"
    self.root_path = 'index.html'

    html_filters.push 'phpunit/clean_html', 'phpunit/entries', 'title'

    options[:root_title] = 'PHPUnit'
    options[:title] = false

    options[:skip] = %w(
      appendixes.index.html
      appendixes.bibliography.html
      appendixes.copyright.html)

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2014 Sebastian Bergmann<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML
  end
end
