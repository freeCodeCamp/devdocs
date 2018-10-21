module Docs
  class ApachePig < UrlScraper
    self.name = 'Apache Pig'
    self.slug = 'apache_pig'
    self.type = 'simple'
    self.links = {
      home: 'https://pig.apache.org/'
    }

    html_filters.push 'apache_pig/clean_html', 'apache_pig/entries'

    options[:container] = '#content'
    options[:skip] = %w(pig-index.html)
    options[:skip_patterns] = [/\Aapi/, /\Ajdiff/]

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2017 Apache Software Foundation<br>
      Licensed under the Apache Software License version 2.0.
    HTML

    version '0.17' do
      self.release = '0.17.0'
      self.base_url = "https://pig.apache.org/docs/r#{release}/"
    end

    version '0.16' do
      self.release = '0.16.0'
      self.base_url = "https://pig.apache.org/docs/r#{release}/"
    end

    version '0.15' do
      self.release = '0.15.0'
      self.base_url = "https://pig.apache.org/docs/r#{release}/"
    end

    version '0.14' do
      self.release = '0.14.0'
      self.base_url = "https://pig.apache.org/docs/r#{release}/"
    end

    version '0.13' do
      self.release = '0.13.0'
      self.base_url = "https://pig.apache.org/docs/r#{release}/"
    end

  end
end
