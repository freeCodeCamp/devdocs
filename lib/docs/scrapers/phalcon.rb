module Docs
  class Phalcon < UrlScraper
    self.name = 'Phalcon'
    self.slug = 'phalcon'
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
      &copy; 2011&ndash;2016 Phalcon Framework Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    version '3.0.0' do
      self.release = '3.0.0'
      self.base_url = 'https://docs.phalconphp.com/en/{version}/'
    end

    version '2.0.0' do
      self.release = '2.0.0'
      self.base_url = 'https://docs.phalconphp.com/en/{version}/'
    end
  end
end
