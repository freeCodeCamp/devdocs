module Docs
  class Coffeescript < UrlScraper
    self.name = 'CoffeeScript'
    self.type = 'coffeescript'
    self.version = '1.9.0'
    self.base_url = 'http://coffeescript.org'

    html_filters.push 'coffeescript/clean_html', 'coffeescript/entries', 'title'

    options[:title] = 'CoffeeScript'
    options[:container] = '.container'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 Jeremy Ashkenas<br>
      Licensed under the MIT License.
    HTML
  end
end
