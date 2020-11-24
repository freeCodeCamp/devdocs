module Docs
  class Modernizr < UrlScraper
    self.name = 'Modernizr'
    self.type = 'modernizr'
    self.release = '3.11.3'
    self.base_url = 'https://modernizr.com/docs/'
    self.links = {
      home: 'https://modernizr.com/',
      code: 'https://github.com/Modernizr/Modernizr'
    }

    html_filters.push 'modernizr/entries', 'modernizr/clean_html', 'title'

    options[:title] = 'Modernizr'
    options[:container] = '#main'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2020 The Modernizr team<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('modernizr', opts)
    end
  end
end
