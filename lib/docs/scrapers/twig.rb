module Docs
  class Twig < UrlScraper
    self.type = 'twig'

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2016 by SensioLabs<br>
      Licensed under the three clause BSD license.
    HTML

    self.release = '1.24.1'
    self.base_url = 'http://twig.sensiolabs.org/'
    self.root_path = 'documentation'

    html_filters.push 'twig/clean_html', 'twig/entries'

    options[:container] = 'div.bd > div.content'
    options[:skip_patterns] = [/\Aapi/, /\Alicense/]
    options[:skip] = %w(doc/deprecated.html doc/advanced_legacy.html)
  end
end
