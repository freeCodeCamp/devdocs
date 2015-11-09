module Docs
  class Vagrant < UrlScraper
    self.name = 'Vagrant'
    self.type = 'vagrant'
    self.version = '1.7.4'
    self.base_url = 'https://docs.vagrantup.com/v2/'
    self.links = {
      home: 'https://www.vagrantup.com/',
      code: 'https://github.com/mitchellh/vagrant'
    }

    html_filters.push 'vagrant/entries', 'vagrant/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2015 Mitchell Hashimoto<br>
      Licensed under the MIT License.
    HTML
  end
end
