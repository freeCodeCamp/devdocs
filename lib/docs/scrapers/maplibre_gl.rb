module Docs
  class MaplibreGl < UrlScraper
    self.name = 'MapLibre GL JS'
    self.slug = 'maplibre_gl'
    self.type = 'maplibre_gl'
    self.release = '5.24.0'
    self.base_url = 'https://maplibre.org/maplibre-gl-js/docs/'
    self.root_path = '/'
    self.links = {
      home: 'https://maplibre.org/maplibre-gl-js/docs/',
      code: 'https://github.com/maplibre/maplibre-gl-js'
    }

    html_filters.push 'maplibre_gl/clean_html', 'maplibre_gl/entries'

    options[:container] = '.md-content__inner'

    # Only scrape the TypeDoc-generated API reference and the guides.
    # The examples (200+ interactive demos) and the embedded style
    # specification are excluded as they aren't API reference material.
    options[:only_patterns] = [
      %r{\AAPI/classes/},
      %r{\AAPI/functions/},
      %r{\AAPI/type-aliases/},
      %r{\AAPI/interfaces/},
      %r{\AAPI/enumerations/},
      %r{\AAPI/variables/},
      %r{\Aguides/}
    ]

    # The site's navigation links point at the `www.` host, which then
    # redirects (301) to the bare domain used by `base_url`. Rewrite them so
    # they are recognised as internal URLs and get followed.
    options[:fix_urls] = ->(url) do
      url.sub(%r{\Ahttps://www\.maplibre\.org/}, 'https://maplibre.org/')
    end

    options[:attribution] = <<-HTML
      &copy; MapLibre contributors<br>
      Licensed under the 3-Clause BSD License.
    HTML

    def get_latest_version(opts)
      get_npm_version('maplibre-gl', opts)
    end
  end
end
