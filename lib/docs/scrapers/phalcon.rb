module Docs
  class Phalcon < UrlScraper
    self.type = 'phalcon'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://phalconphp.com/',
      code: 'https://github.com/phalcon/cphalcon/'
    }

    html_filters.push 'phalcon/clean_html', 'phalcon/entries'

    options[:root_title] = 'Phalcon'
    options[:only_patterns] = [/reference\//, /api\//]
    options[:skip] = %w(
      api/index.html
      reference/license.html)

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 Phalcon Framework Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    version '3' do
      self.release = '3.1.1'
      self.base_url = 'https://docs.phalconphp.com/en/latest/'
    end

    version '2' do
      self.release = '2.0.13'
      self.base_url = 'https://docs.phalconphp.com/en/2.0.0/'
    end
  end
end
