module Docs
  class Pygame < UrlScraper

    self.type = 'simple'

    self.release = 'v1.9.4.dev0'

    self.initial_paths = ['py-modindex.html']
    self.base_url = 'https://www.pygame.org/docs/'
    self.root_path = 'py-modindex.html'
    self.initial_paths = []

    self.links = {
      home: 'https://www.pygame.org/',
      code: 'https://github.com/pygame/pygame'
    }

    html_filters.push 'pygame/clean_html', 'pygame/entries'

    options[:only_patterns] = [/ref\//]

    options[:attribution] = <<-HTML
         &copy; Pygame Developpers.
    HTML
  end
end
