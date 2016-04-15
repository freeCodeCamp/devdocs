module Docs
  class Pig < UrlScraper
    self.name = 'Pig'
    self.type = 'pig'
    self.links = {
      home: 'https://pig.apache.org/'
    }

    html_filters.push 'pig/clean_html', 'pig/entries'

    options[:skip] = %w( pig-index.html )

    options[:skip_patterns] = [
      /\Aapi/,
      /\Ajdiff/
    ]

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2016 Apache Software Foundation<br>
      Licensed under the Apache Software License version 2.0.
    HTML

    version '0.15.0' do
      self.release = '0.15.0'
      self.base_url = "http://pig.apache.org/docs/r#{release}/"
    end

    version '0.14.0' do
      self.release = '0.14.0'
      self.base_url = "http://pig.apache.org/docs/r#{release}/"
    end

    version '0.13.0' do
      self.release = '0.13.0'
      self.base_url = "http://pig.apache.org/docs/r#{release}/"
    end

  end
end
