module Docs
  class Nokogiri2 < UrlScraper
    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.type = 'rdoc'
    self.release = '1.19.4'
    self.base_url = 'https://nokogiri.org/rdoc/'
    self.root_path = 'index.html'

    html_filters.replace 'container', 'nokogiri2/container'
    html_filters.push 'nokogiri2/entries', 'nokogiri2/clean_html', 'title'

    options[:title] = false
    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/, /\AXSD/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2026 by Mike Dalessio, Aaron Patterson, Yoko Harada, Akinori MUSHA, John Shahid,<br>
      Karol Bucek, Sam Ruby, Craig Barnes, Stephen Checkoway, Lars Kanis, Sergio Arbeo,<br>
      Timothy Elliott, Nobuyoshi Nakada, Charles Nutter, Patrick Mahoney
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('sparklemotion', 'nokogiri', opts)
    end
  end
end
