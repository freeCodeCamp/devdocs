module Docs
  class Phalcon < UrlScraper
    self.name = 'Phalcon'
    self.slug = 'phalcon'
    self.type = 'phalcon'
    self.base_url = 'https://docs.phalconphp.com/en/latest/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://phalconphp.com/',
      code: 'https://github.com/phalcon/cphalcon/'
    }

    html_filters.push 'phalcon/clean_html', 'phalcon/entries', 'title'

    options[:root_title] = 'Phalcon'
    options[:only_patterns] = [/reference\//, /api\//]
    options[:skip_patterns] = [/api\/index/]

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2015 the Phalcon Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML
  end
end
