module Docs
  class Pygame < UrlScraper
    self.type = 'pygame'
    self.release = '2.4.0'
    self.base_url = 'https://www.pygame.org/docs/'
    self.root_path = 'py-modindex.html'
    self.links = {
      home: 'https://www.pygame.org/',
      code: 'https://github.com/pygame/pygame'
    }

    html_filters.push 'pygame/pre_clean_html', 'pygame/entries', 'pygame/clean_html'

    options[:only_patterns] = [/ref\//]

    options[:attribution] = <<-HTML
      &copy; Pygame Developers.<br>
      Licensed under the GNU LGPL License version 2.1.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('pygame', 'pygame', opts)
    end
  end
end
