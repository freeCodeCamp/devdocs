module Docs
  class Graphviz < UrlScraper
    self.name = 'Graphviz'
    self.slug = 'graphviz'
    self.type = 'simple'

    self.links = {
      home: 'https://www.graphviz.org/',
      code: 'https://gitlab.com/graphviz/graphviz'
    }

    options[:container] = 'main'

    # These images are too large:
    # 980KB https://www.graphviz.org/doc/info/plugins.png
    # 650KB https://www.graphviz.org/Gallery/twopi/twopi2.svg
    # All other files are under 100KB
    options[:max_image_size] = 100_000

    # TODO: the UrlScraper is very unreliable on this website.
    # I often get several errors:
    # - SSL connect error
    # - Failure when receiving data from the peer
    # - was slow to process (30s)
    # Setting a :rate_limit doesn't help.
    # We have to figure out a more reliable solution.
    #options[:rate_limit] = 100

    options[:attribution] = <<-HTML
      &copy; 2025 The Graphviz Authors<br>
      Licensed under the Eclipse Public License 1.0.
    HTML

    html_filters.push 'graphviz/entries', 'graphviz/clean_html'

    self.release = '14.01'
    self.base_url = 'https://www.graphviz.org/'
    self.root_path = 'documentation/'
    options[:only_patterns] = [
      /^documentation\//,
      /^doc\//,
      /^docs\//,
    ]
    options[:replace_paths] = {
      # Redirections:
      'docs/outputs/cmap/' => 'docs/outputs/imap/',
      'doc/info/output.html' => 'docs/outputs/',
    }

    def get_latest_version(opts)
      tags = get_gitlab_tags('gitlab.com', 'graphviz', 'graphviz', opts)
      tags[0]['name']
    end
  end
end
