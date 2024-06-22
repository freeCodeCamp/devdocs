module Docs
  class Express < UrlScraper
    self.name = 'Express'
    self.type = 'express'
    self.release = '4.18.1'
    self.base_url = 'https://expressjs.com/en/'
    self.root_path = '4x/api.html'
    self.initial_paths = %w(
      starter/installing.html
      guide/routing.html
      advanced/developing-template-engines.html )
    self.links = {
      home: 'https://expressjs.com/',
      code: 'https://github.com/strongloop/express/'
    }

    html_filters.push 'express/clean_html', 'express/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Express'

    options[:only_patterns] = [
      /\Astarter/,
      /\Aguide/,
      /\Aadvanced/ ]

    options[:attribution] = <<-HTML
      &copy; 2017 StrongLoop, IBM, and other expressjs.com contributors.<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v3.0.
    HTML

    def get_latest_version(opts)
      get_npm_version('express', opts)
    end
  end
end
