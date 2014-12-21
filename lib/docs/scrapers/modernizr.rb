module Docs
  class Modernizr < UrlScraper
    self.name = 'Modernizr'
    self.type = 'modernizr'
    self.version = '2.8.3'
    self.base_url = 'http://modernizr.com/docs/'

    html_filters.push 'modernizr/entries', 'modernizr/clean_html', 'title'

    options[:title] = 'Modernizr'
    options[:container] = '#documentation'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2014 Modernizr<br>
      Licensed under the MIT License.
    HTML
  end
end
