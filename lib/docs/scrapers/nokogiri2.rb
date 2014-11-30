module Docs
  class Nokogiri2 < Rdoc
    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.version = '1.6.4'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Nokogiri'

    html_filters.replace 'rdoc/entries', 'nokogiri2/entries'

    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2014 Aaron Patterson, Mike Dalessio, Charles Nutter,<br>
      Sergio Arbeo, Patrick Mahoney, Yoko Harada, Akinori Musha<br>
      Licensed under the MIT License.
    HTML
  end
end
