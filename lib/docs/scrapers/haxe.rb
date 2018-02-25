module Docs
  class Haxe < UrlScraper
    self.name = 'Haxe'
    self.type = 'haxe'
    self.release = '3.4.7'
    self.base_url = 'https://api.haxe.org/'

    html_filters.push 'haxe/clean_html', 'haxe/entries'

    options[:container] = '.span9'

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2016 Haxe Foundation<br>
      Licensed under a MIT license.
    HTML

    version do
      self.links = {
        home: 'https://haxe.org',
        code: 'https://github.com/HaxeFoundation/haxe'
      }

      options[:skip_patterns] = [/\A(?:cpp|cs|flash|java|js|neko|php|python)/i]
    end

    version 'C++' do
      self.base_url = 'https://api.haxe.org/cpp/'
    end

    version 'C#' do
      self.base_url = 'https://api.haxe.org/cs/'
    end

    version 'Flash' do
      self.base_url = 'https://api.haxe.org/flash/'
    end

    version 'Java' do
      self.base_url = 'https://api.haxe.org/java/'
    end

    version 'JavaScript' do
      self.base_url = 'https://api.haxe.org/js/'
    end

    version 'Neko' do
      self.base_url = 'https://api.haxe.org/neko/'
    end

    version 'PHP' do
      self.base_url = 'https://api.haxe.org/php/'
    end

    version 'Python' do
      self.base_url = 'https://api.haxe.org/python/'
    end
  end
end
