module Docs
  class Nokogiri2 < Rdoc
    # Instructions:
    #   1. Download the latest release at https://github.com/sparklemotion/nokogiri/releases
    #   2. Run "bundle install && bundle exec rake docs" (in the Nokogiri directory)
    #   4. Copy the "doc" directory to "docs/nokogiri"

    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.release = '1.13.0'
    self.base_url = "https://nokogiri.org/rdoc/"

    html_filters.replace 'rdoc/entries', 'nokogiri2/entries'

    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/, /\AXSD/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2021 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo,<br>
      Patrick Mahoney, Yoko Harada, Akinori MUSHA, John Shahid, Lars Kanis<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('sparklemotion', 'nokogiri', opts)
    end
  end
end
