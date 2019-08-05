module Docs
  class Twig < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.initial_paths = %w(extensions/index.html)
    self.links = {
      home: 'https://twig.symfony.com/',
      code: 'https://github.com/twigphp/Twig'
    }

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2018 by the Twig Team<br>
      Licensed under the three clause BSD license.<br>
      The Twig logo is &copy; 2010&ndash;2018 Symfony
    HTML

    html_filters.push 'twig/clean_html', 'twig/entries'

    options[:container] = 'div.bd > div.content'
    options[:skip] = %w(deprecated.html advanced_legacy.html)

    version '2' do
      self.release = '2.5.0'
      self.base_url = 'https://twig.symfony.com/doc/2.x/'
    end

    version '1' do
      self.release = '1.34.3'
      self.base_url = 'https://twig.symfony.com/doc/1.x/'
    end

    def get_latest_version(opts)
      tags = get_github_tags('twigphp', 'Twig', opts)
      tags[0]['name'][1..-1]
    end
  end
end
