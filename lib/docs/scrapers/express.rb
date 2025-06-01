module Docs
  class Express < UrlScraper
    self.name = 'Express'
    self.type = 'express'
    self.base_url = 'https://expressjs.com/en/'
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

    version do
      self.release = '5.1.0'
      self.root_path = '5x/api.html'
    end

    version '4' do
      self.release = '4.21.2'
      self.root_path = '4x/api.html'
    end

    def get_latest_version(opts)
      get_npm_version('express', opts)
    end
  end
end
