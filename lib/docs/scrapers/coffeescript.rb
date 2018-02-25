module Docs
  class Coffeescript < UrlScraper
    self.name = 'CoffeeScript'
    self.type = 'coffeescript'
    self.links = {
      home: 'http://coffeescript.org',
      code: 'https://github.com/jashkenas/coffeescript'
    }

    options[:title] = 'CoffeeScript'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2018 Jeremy Ashkenas<br>
      Licensed under the MIT License.
    HTML

    version '2' do
      self.release = '2.2.2'
      self.base_url = 'http://coffeescript.org/'

      html_filters.push 'coffeescript/entries', 'coffeescript/clean_html', 'title'
    end

    version '1' do
      self.release = '1.12.6'
      self.base_url = 'http://coffeescript.org/v1/'

      html_filters.push 'coffeescript/clean_html_v1', 'coffeescript/entries_v1', 'title'

      options[:container] = '.container'
    end
  end
end
