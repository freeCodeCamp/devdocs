module Docs
  class Coffeescript < UrlScraper
    self.name = 'CoffeeScript'
    self.type = 'coffeescript'
    self.links = {
      home: 'https://coffeescript.org',
      code: 'https://github.com/jashkenas/coffeescript'
    }

    options[:title] = 'CoffeeScript'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2020 Jeremy Ashkenas<br>
      Licensed under the MIT License.
    HTML

    version '2' do
      self.release = '2.5.1'
      self.base_url = 'https://coffeescript.org/'

      html_filters.push 'coffeescript/entries', 'coffeescript/clean_html', 'title'
    end

    version '1' do
      self.release = '1.12.7'
      self.base_url = 'https://coffeescript.org/v1/'

      html_filters.push 'coffeescript/clean_html_v1', 'coffeescript/entries_v1', 'title'

      options[:container] = '.container'
    end

    def get_latest_version(opts)
      get_npm_version('coffeescript', opts)
    end
  end
end
