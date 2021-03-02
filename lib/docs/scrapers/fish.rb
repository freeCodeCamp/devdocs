module Docs
  class Fish < UrlScraper
    self.name = 'Fish'
    self.type = 'simple'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://fishshell.com/',
      code: 'https://github.com/fish-shell/fish-shell'
    }

    options[:skip] = %w(design.html license.html)

    # https://fishshell.com/docs/current/license.html
    options[:attribution] = <<-HTML
      &copy; 2020 fish-shell developers<br>
      Licensed under the GNU General Public License, version 2.
    HTML

    version '3.2' do
      self.release = '3.2.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      options[:skip].concat %w(genindex.html relnotes.html)
      html_filters.push 'sphinx/clean_html', 'fish/clean_html_sphinx', 'fish/entries_sphinx'
    end

    version '3.1' do
      self.release = '3.1.2'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      options[:skip].concat %w(genindex.html commands.html)
      html_filters.push 'sphinx/clean_html', 'fish/clean_html_sphinx', 'fish/entries_sphinx'
    end

    version '3.0' do
      self.release = '3.0.1'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.7' do
      self.release = '2.7.1'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.6' do
      self.release = '2.6.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.5' do
      self.release = '2.5.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.4' do
      self.release = '2.4.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.3' do
      self.release = '2.3.1'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    version '2.2' do
      self.release = '2.2.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"

      html_filters.push 'fish/clean_html_custom', 'fish/entries_custom'
    end

    def get_latest_version(opts)
      get_latest_github_release('fish-shell', 'fish-shell', opts)
    end
  end
end
