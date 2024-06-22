module Docs
  class Phpunit < UrlScraper
    self.name = 'PHPUnit'
    self.type = 'phpunit'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://phpunit.de/',
      code: 'https://github.com/sebastianbergmann/phpunit'
    }

    options[:skip] = [
      'bibliography.html',
      'copyright.html'
    ]

    options[:root_title] = 'PHPUnit'
    options[:title] = false

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2020 Sebastian Bergmann<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML

    FILTERS = %w(phpunit/clean_html phpunit/entries title)

    version '9' do
      self.release = '9.5'
      self.base_url = "https://phpunit.readthedocs.io/en/#{release}/"

      html_filters.push FILTERS

      options[:container] = '.document'
    end

    version '8' do
      self.release = '8.5'
      self.base_url = "https://phpunit.readthedocs.io/en/#{release}/"

      html_filters.push FILTERS

      options[:container] = '.document'
    end

    OLDFILTERS = %w(phpunit/clean_html_old phpunit/entries_old title)

    OLDSKIP = %w(
      appendixes.index.html
      appendixes.bibliography.html
      appendixes.copyright.html)

    version '6' do
      self.release = '6.5'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"

      html_filters.push OLDFILTERS

      options[:skip] = OLDSKIP
    end

    version '5' do
      self.release = '5.7'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"

      html_filters.push OLDFILTERS

      options[:skip] = OLDSKIP
    end

    version '4' do
      self.release = '4.8'
      self.base_url = "https://phpunit.de/manual/#{release}/en/"

      options[:skip] = OLDSKIP

      html_filters.push OLDFILTERS
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://phpunit.readthedocs.io/', opts)
      label = doc.at_css('.rst-current-version').content.strip
      label.scan(/v: ([0-9.]+)/)[0][0]
    end

  end
end
