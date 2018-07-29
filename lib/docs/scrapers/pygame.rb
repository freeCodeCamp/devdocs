module Docs
  class Pygame < UrlScraper
    self.type = 'simple'
    self.release = '1.9.4'
    self.root_path = 'py-modindex.html'
    self.links = {
      home: 'https://www.pygame.org/',
      code: 'https://github.com/pygame/pygame'
    }

    html_filters.push 'pygame/clean_html', 'pygame/entries'

    options[:only_patterns] = [/ref\//]

    options[:attribution] = <<-HTML
      &copy; Pygame Developpers.<br>
      Licensed under the GNU LGPL License version 2.1.
    HTML
  end
end
