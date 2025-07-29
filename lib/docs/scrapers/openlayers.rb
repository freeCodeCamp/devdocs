module Docs
  class Openlayers < UrlScraper
    self.name = 'OpenLayers'
    self.type = 'openlayers'
    self.slug = 'openlayers'
    self.release = '10.6.1'
    self.base_url = "https://openlayers.org/en/latest/apidoc/"
    self.links = {
      home: 'https://openlayers.org/',
      code: 'https://github.com/openlayers/openlayers'
    }

    html_filters.push 'openlayers/entries', 'openlayers/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2005-present, OpenLayers Contributors All rights reserved.
      Licensed under the BSD 2-Clause License.
    HTML

    def get_latest_version(opts)
      get_npm_version('ol', opts)
    end
  end
end
