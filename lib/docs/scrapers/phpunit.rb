module Docs
  class Phpunit < UrlScraper
    self.name = 'PHPUnit'
    self.type = 'phpunit'
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
      &copy; 2005&ndash;2017 Sebastian Bergmann<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML

    version '6' do
      self.release = '6.5'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"
    end

    version '5' do
      self.release = '5.7'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"
    end

    version '4' do
      self.release = '4.8'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://phpunit.readthedocs.io/', opts)
      label = doc.at_css('.rst-current-version').content.strip
      label.scan(/v: ([0-9.]+)/)[0][0]
    end
  end
end
