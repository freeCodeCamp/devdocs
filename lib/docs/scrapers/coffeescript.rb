module Docs
  class Coffeescript < UrlScraper
    self.name = 'CoffeeScript'
    self.type = 'coffeescript'
    self.version = '1.6.3'
    self.base_url = 'http://coffeescript.org'

    html_filters.push 'coffeescript/clean_html', 'coffeescript/entries', 'title'

    options[:title] = 'CoffeeScript'
    options[:container] = '.container'
    options[:skip_links] = -> (_) { true }

    options[:attribution] = <<-HTML.strip_heredoc
      &copy; 2009&ndash;2013 Jeremy Ashkenas<br>
      Licensed under the MIT License.
    HTML
  end
end
