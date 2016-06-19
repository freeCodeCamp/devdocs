module Docs
  class Express < UrlScraper
    self.name = 'Express'
    self.type = 'express'
    self.release = '4.14.0'
    self.base_url = 'http://expressjs.com/en/'
    self.root_path = '4x/api.html'
    self.initial_paths = %w(
      starter/installing.html
      guide/routing.html
      advanced/developing-template-engines.html )
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
      /\Aadvanced/ ]

    options[:attribution] = <<-HTML
      &copy; 2016 StrongLoop, IBM, and other expressjs.com contributors.
    HTML
  end
end
