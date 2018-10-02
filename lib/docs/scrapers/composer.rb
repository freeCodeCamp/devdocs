module Docs
  class Composer < UrlScraper
    self.name = 'Composer'
    self.type = 'simple'

    self.links = {
      home: 'https://getcomposer.org',
      code: 'https://github.com/composer/composer'
    }

    html_filters.push 'composer/clean_html', 'composer/entries'

    self.release = '1.7.2'
    self.base_url = 'https://getcomposer.org/doc/'

    options[:container] = '#main'

    options[:skip_patterns] = [
      /^faqs/
    ]

    options[:attribution] = <<-HTML
      &copy; Nils Adermann, Jordi Boggiano<br>
      Licensed under the MIT License.
    HTML
  end
end
