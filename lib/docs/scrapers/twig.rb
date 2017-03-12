module Docs
  class Twig < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.initial_paths = %w(extensions/index.html)
    self.links = {
      home: 'http://twig.sensiolabs.org/',
      code: 'https://github.com/twigphp/Twig'
    }

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2017 by the Twig Team<br>
      Licensed under the three clause BSD license.<br>
      The Twig logo is &copy; 2010&ndash;2017 SensioLabs
    HTML

    html_filters.push 'twig/clean_html', 'twig/entries'

    options[:container] = 'div.bd > div.content'
    options[:skip] = %w(deprecated.html advanced_legacy.html)

    version '2' do
      self.release = '2.2.0'
      self.base_url = 'http://twig.sensiolabs.org/doc/2.x/'
    end

    version '1' do
      self.release = '1.32.0'
      self.base_url = 'http://twig.sensiolabs.org/doc/1.x/'
    end
  end
end
