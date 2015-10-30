module Docs
  class Vagrant < UrlScraper
    self.name = 'Vagrant'
    self.slug = 'vagrant'
    self.type = 'vagrant'
    self.version = '1.7.4'
    self.base_url = 'http://docs.vagrantup.com/v2/'
    self.links = {
      home: 'http://www.vagrantup.com/'
    }

    html_filters.push 'vagrant/clean_html', 'vagrant/entries'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2015 Mitchell Hashimoto<br>
      Licensed under the MIT License.
    HTML
  end
end
