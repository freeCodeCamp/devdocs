module Docs
  class Fish < UrlScraper
    self.name = 'Fish'
    self.type = 'simple'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://fishshell.com/',
      code: 'https://github.com/fish-shell/fish-shell'
    }

    html_filters.push 'fish/clean_html', 'fish/entries'

    options[:skip] = %w(design.html license.html)

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2009 Axel Liljencrantz<br>
      Licensed under the GNU General Public License, version 2.
    HTML

    version '2.7' do
      self.release = '2.7.1'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end

    version '2.6' do
      self.release = '2.6.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end

    version '2.5' do
      self.release = '2.5.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end

    version '2.4' do
      self.release = '2.4.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end

    version '2.3' do
      self.release = '2.3.1'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end

    version '2.2' do
      self.release = '2.2.0'
      self.base_url = "https://fishshell.com/docs/#{version}/"
    end
  end
end
