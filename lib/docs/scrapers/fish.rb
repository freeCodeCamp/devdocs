module Docs
  class Fish < UrlScraper
    self.name = 'Fish'
    self.type = 'fish'
    self.links = {
      home: 'http://fishshell.com/',
      code: 'https://github.com/fish-shell/fish-shell'
    }

    html_filters.push 'fish/clean_html', 'fish/entries'

    options[:only] = %w(
      index.html
      tutorial.html
      commands.html
      faq.html
    )

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2009 Axel Liljencrantz<br>
      &copy; 2009&ndash;2016 The fish contributors<br>
      Licensed under the GNU General Public License, version 2.
    HTML

    version '2.3' do
      self.release = '2.3.1'
      self.base_url = "http://fishshell.com/docs/#{version}/"
      self.root_path = 'index.html'
    end
    version '2.2' do
      self.release = '2.2.0'
      self.base_url = "http://fishshell.com/docs/#{version}/"
      self.root_path = 'index.html'
    end
  end
end
