module Docs
  class Express < UrlScraper
    self.name = 'Express'
    self.type = 'express'
    self.release = '4.13.0'
    self.base_url = 'http://expressjs.com/'
    self.root_path = '4x/api.html'
    self.links = {
      home: 'http://expressjs.com/',
      code: 'https://github.com/strongloop/express/'
    }

    html_filters.push 'express/clean_html', 'express/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Express'
    options[:container] = ->(filter) { filter.root_page? ? '#api-doc' : '.content' }

    options[:only_patterns] = [
      /\Astarter/,
      /\Aguide/,
      /\Aadvanced/
    ]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 TJ Holowaychuk<br>
      Licensed under the MIT License.
    HTML
  end
end
