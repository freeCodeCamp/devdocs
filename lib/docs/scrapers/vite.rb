module Docs
  class Vite < UrlScraper
    self.name = 'Vite'
    self.slug = 'vite'
    self.type = 'simple'
    self.links = {
      home: 'https://vite.dev/',
      code: 'https://github.com/vitejs/vite'
    }

    options[:root_title] = 'Vite'

    options[:attribution] = <<-HTML
      &copy; 2019–present, Yuxi (Evan) You and Vite contributors<br>
      Licensed under the MIT License.
    HTML

    options[:skip] = %w(team.html team)
    options[:skip_patterns] = [/\Ablog/, /\Aplugins/]

    self.initial_paths = %w(guide/)
    html_filters.push 'vite/entries', 'vite/clean_html'

    version do
      self.release = '7.1.2'
      self.base_url = 'https://vite.dev/'
    end

    version '6' do
      self.release = '6.3.5'
      self.base_url = 'https://v6.vite.dev/'
    end

    version '5' do
      self.release = '5.4.11'
      self.base_url = 'https://v5.vite.dev/'
    end

    version '4' do
      self.release = '4.5.5'
      self.base_url = 'https://v4.vite.dev/'
    end

    version '3' do
      self.release = '3.2.11'
      self.base_url = 'https://v3.vite.dev/'
    end

    def get_latest_version(opts)
      get_npm_version('vite', opts)
    end
  end
end
