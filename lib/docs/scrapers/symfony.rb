module Docs
  class Symfony < UrlScraper
    self.name = 'Symfony'
    self.slug = 'symfony'
    self.type = 'laravel'
    self.root_path = 'namespaces.html'
    self.initial_paths = %w(classes.html)
    self.links = {
      home: 'http://symfony.com/',
      code: 'https://github.com/symfony/symfony'
    }

    html_filters.push 'symfony/entries', 'symfony/clean_html'

    options[:skip] = %w(
      panel.html
      namespaces.html
      interfaces.html
      traits.html
      doc-index.html
      search.html
      Symfony.html)

    options[:attribution] = <<-HTML
      &copy; 2004&ndash;2016 Fabien Potencier<br>
      Licensed under the MIT License.
    HTML

    version '3.1' do
      self.release = '3.1.2'
      self.base_url = "http://api.symfony.com/#{version}/"
    end

    version '3.0' do
      self.release = '3.0.1'
      self.base_url = "http://api.symfony.com/#{version}/"
    end

    version '2.8' do
      self.release = '2.8.2'
      self.base_url = "http://api.symfony.com/#{version}/"
    end

    version '2.7' do
      self.release = '2.7.9'
      self.base_url = "http://api.symfony.com/#{version}/"
    end
  end
end
