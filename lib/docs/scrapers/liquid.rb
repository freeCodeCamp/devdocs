module Docs
  class Liquid < UrlScraper
    self.name = 'Liquid'
    self.type = 'liquid'
    self.base_url = "https://shopify.github.io/liquid/"
    self.links = {
      home: 'http://liquidmarkup.org/',
      code: 'https://github.com/shopify/liquid'
    }

    html_filters.push 'liquid/entries', 'liquid/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2005, 2006 Tobias Luetke<br>
      Licensed under the MIT License.
    HTML

  end
end
