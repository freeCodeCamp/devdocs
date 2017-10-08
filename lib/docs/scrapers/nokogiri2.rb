module Docs
  class Nokogiri2 < Rdoc
    self.name = 'Nokogiri'
    self.slug = 'nokogiri'
    self.release = '1.8.1'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Nokogiri'

    html_filters.replace 'rdoc/entries', 'nokogiri2/entries'

    options[:root_title] = 'Nokogiri'
    options[:only_patterns] = [/\ANokogiri/, /\AXSD/]

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2017 Aaron Patterson, Mike Dalessio, Charles Nutter, Sergio Arbeo<br>
      Patrick Mahoney, Yoko Harada, Akinori Musha, John Shahid<br>
      Licensed under the MIT License.
    HTML
  end
end
