module Docs
  class Liquid < UrlScraper
    self.name = 'Liquid'
    self.type = 'liquid'
    self.base_url = 'https://shopify.github.io/liquid/'
    self.release = '5.0.0'
    self.links = {
      home: 'https://shopify.github.io/liquid/',
      code: 'https://github.com/Shopify/liquid'
    }

    html_filters.push 'liquid/entries', 'liquid/clean_html', 'title'

    options[:title] = false
    options[:root_title] = 'Liquid'
    options[:trailing_slash] = true

    options[:attribution] = <<-HTML
      &copy; 2005, 2006 Tobias Luetke<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      tags = get_github_tags('Shopify', 'liquid', opts)
      tags[0]['name'][1..-1]
    end

  end
end
