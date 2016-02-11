module Docs
  class Haxe < UrlScraper
    self.name = 'Haxe'
    self.type = 'haxe'
    self.release = '3.2.0'
    self.base_url = 'http://api.haxe.org'
    self.links = {
      home: 'http://haxe.org',
      code: 'https://github.com/HaxeFoundation/haxe'
    }

    html_filters.push 'haxe/clean_html', 'haxe/entries'

    options[:container] = '.span9'
    options[:title] = nil
    options[:root_title] = 'Haxe'

    options[:attribution] = <<-HTML
      &copy; HaxeFoundation<br>
      Licensed under a MIT license.
    HTML
  end  
end
