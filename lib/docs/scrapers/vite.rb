module Docs
  class Vite < UrlScraper
    self.name = 'Vite'
    self.slug = 'vite'
    self.type = 'simple'
    self.links = {
      home: 'https://vitejs.dev/',
      code: 'https://github.com/vitejs/vite'
    }

    options[:root_title] = 'Vite'

    options[:attribution] = <<-HTML
      &copy; 2019–present, Yuxi (Evan) You and Vite contributors<br>
      Licensed under the MIT License.
    HTML

    options[:skip] = %w(team.html plugins/)

    self.release = '3.1.3'
    self.base_url = 'https://vitejs.dev/'
    self.initial_paths = %w(guide/)
    html_filters.push 'vite/entries', 'vite/clean_html'

    def get_latest_version(opts)
      get_npm_version('vite', opts)
    end
  end
end
