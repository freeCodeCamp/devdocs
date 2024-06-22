module Docs
  class Nokogiri2 < Rdoc
    # Instructions:
    #   1. Download the latest release at https://github.com/sparklemotion/nokogiri/releases
    #   2. Run "bundle install && bundle exec rake docs" (in the Nokogiri directory)
    #   4. Copy the "doc" directory to "docs/nokogiri"

    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.release = '1.14.2'
    self.base_url = "https://nokogiri.org/rdoc/"

    html_filters.replace 'rdoc/entries', 'nokogiri2/entries'

    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/, /\AXSD/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2023 by Mike Dalessio, Aaron Patterson, Yoko Harada, Akinori MUSHA, John Shahid,<br>
      Karol Bucek, Sam Ruby, Craig Barnes, Stephen Checkoway, Lars Kanis, Sergio Arbeo,<br>
      Timothy Elliott, Nobuyoshi Nakada, Charles Nutter, Patrick Mahoney
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('sparklemotion', 'nokogiri', opts)
    end
  end
end
