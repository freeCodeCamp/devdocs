module Docs
  class Nokogiri2 < Rdoc
    # Instructions:
    #   1. Download the latest release at https://github.com/sparklemotion/nokogiri/releases
    #   2. Run "bundle install && bundle exec rake docs" (in the Nokogiri directory)
    #   4. Copy the "doc" directory to "docs/nokgiri"

    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.release = '1.9.0'

    html_filters.replace 'rdoc/entries', 'nokogiri2/entries'

    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/, /\AXSD/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2018 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo,<br>
      Patrick Mahoney, Yoko Harada, Akinori Musha, John Shahid, Lars Kanis<br>
      Licensed under the MIT License.
    HTML
  end
end
