module Docs
  class Twig < UrlScraper
    self.type = 'sphinx'
    self.release = '1.24'
    self.base_url = 'http://twig.sensiolabs.org/doc/'
    self.root_path = 'index.html'
    self.initial_paths = %w(extensions/index.html)

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2016 by the Twig Team<br>
      Licensed under the three clause BSD license.<br>
      The Twig logo is &copy; 2010&ndash;2016 SensioLabs
    HTML

    html_filters.push 'twig/clean_html', 'twig/entries'

    options[:container] = 'div.bd > div.content'
    options[:skip] = %w(deprecated.html advanced_legacy.html)
  end
end
